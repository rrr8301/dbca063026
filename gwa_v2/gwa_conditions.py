"""GitHub Actions expression evaluation for Static Condition Resolution (SCR).

Parses an expression into an AST and evaluates it with GitHub's semantics:
loose equality that coerces mismatched types to numbers, case-insensitive
string comparison, `&&` / `||` that return operand values, and the built-in
functions. Whatever depends on information that is not available statically
evaluates to an `Unknown`, and the logic is three-valued: `x && false` is
still false and `x || true` still true when `x` is unknown.

    resolve_condition("runner.os == 'Linux' && matrix.python == '3.12'", contexts)
        -> ("TRUE" | "FALSE" | "UNKNOWN", evidence)

A TRUE condition does not mean the step runs: a step without a status
function has an implicit `success()`, and earlier failures, cancellation or
timeouts are runtime facts. The evidence records the implicit status check.
"""
import json
import math
import re

TRUE, FALSE, UNKNOWN = "TRUE", "FALSE", "UNKNOWN"
STATUS_FUNCTIONS = ("success", "failure", "cancelled", "always")
WRAPPED = re.compile(r"^\s*\$\{\{(.*)\}\}\s*$", re.DOTALL)


class Unknown:
    """A value not known statically, possibly with known truthiness."""

    def __init__(self, truthy=None, why=""):
        self.truthy = truthy
        self.why = why

    def __repr__(self):
        return f"Unknown({self.truthy}, {self.why!r})"


class Partial(dict):
    """A context of which only some properties are known: the others are Unknown, not null."""


class ExpressionError(ValueError):
    pass


# ── tokenizer and parser ──────────────────────────────────────────────────────
TOKEN = re.compile(r"""
    (?P<ws>\s+)
  | (?P<string>'(?:[^']|'')*')
  | (?P<number>-?(?:0x[0-9a-fA-F]+|(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?))
  | (?P<op>==|!=|<=|>=|&&|\|\||[!<>()\[\].,*])
  | (?P<ident>[A-Za-z_][A-Za-z0-9_-]*)
""", re.VERBOSE)


def tokenize(text):
    tokens, position = [], 0
    while position < len(text):
        m = TOKEN.match(text, position)
        if not m:
            raise ExpressionError(f"unexpected {text[position:position + 10]!r}")
        position = m.end()
        kind = m.lastgroup
        if kind == "ws":
            continue
        value = m.group(kind)
        if kind == "string":
            value = value[1:-1].replace("''", "'")
        elif kind == "number":
            value = float(int(value, 16)) if value.lower().startswith(("0x", "-0x")) else float(value)
        tokens.append((kind, value))
    tokens.append(("end", None))
    return tokens


class Parser:
    """Precedence, loosest first: ||, &&, == !=, < <= > >=, !, then . [] () ."""

    def __init__(self, text):
        self.tokens = tokenize(text)
        self.i = 0

    def peek(self, value=None):
        kind, v = self.tokens[self.i]
        return v == value and kind == "op" if value is not None else (kind, v)

    def take(self, value=None):
        token = self.tokens[self.i]
        if value is not None and not (token[0] == "op" and token[1] == value):
            raise ExpressionError(f"expected {value!r}, got {token[1]!r}")
        self.i += 1
        return token

    def parse(self):
        node = self.or_()
        if self.tokens[self.i][0] != "end":
            raise ExpressionError(f"unexpected {self.tokens[self.i][1]!r}")
        return node

    def binary(self, operators, operand):
        node = operand()
        while self.tokens[self.i][0] == "op" and self.tokens[self.i][1] in operators:
            op = self.take()[1]
            node = ("binary", op, node, operand())
        return node

    def or_(self):
        return self.binary(("||",), self.and_)

    def and_(self):
        return self.binary(("&&",), self.equality)

    def equality(self):
        return self.binary(("==", "!="), self.comparison)

    def comparison(self):
        return self.binary(("<", "<=", ">", ">="), self.unary)

    def unary(self):
        if self.peek("!"):
            self.take()
            return ("not", self.unary())
        return self.postfix()

    def postfix(self):
        node = self.primary()
        while True:
            if self.peek("."):
                self.take()
                if self.peek("*"):
                    self.take()
                    node = ("filter", node)
                else:
                    kind, name = self.take()
                    if kind != "ident":
                        raise ExpressionError(f"expected a property name, got {name!r}")
                    node = ("property", node, name)
            elif self.peek("["):
                self.take()
                if self.peek("*"):
                    self.take()
                    node = ("filter", node)
                else:
                    node = ("index", node, self.or_())
                self.take("]")
            else:
                return node

    def primary(self):
        kind, value = self.take()
        if kind in ("string", "number"):
            return ("literal", value)
        if kind == "op" and value == "(":
            node = self.or_()
            self.take(")")
            return node
        if kind == "ident":
            lowered = value.lower()
            if self.peek("("):
                self.take()
                args = []
                if not self.peek(")"):
                    args.append(self.or_())
                    while self.peek(","):
                        self.take()
                        args.append(self.or_())
                self.take(")")
                return ("call", lowered, args)
            if value in ("true", "false"):
                return ("literal", value == "true")
            if value == "null":
                return ("literal", None)
            if value in ("NaN", "Infinity"):
                return ("literal", math.nan if value == "NaN" else math.inf)
            return ("context", value)
        raise ExpressionError(f"unexpected {value!r}")


# ── value semantics ───────────────────────────────────────────────────────────
def truthy(value):
    """True / False, or None when unknown."""
    if isinstance(value, Unknown):
        return value.truthy
    if value is None or value is False:
        return False
    if isinstance(value, bool):
        return True
    if isinstance(value, (int, float)):
        return not (value == 0 or math.isnan(value))
    if isinstance(value, str):
        return value != ""
    return True                              # arrays and objects


def to_number(value):
    if value is None:
        return 0.0
    if isinstance(value, bool):
        return 1.0 if value else 0.0
    if isinstance(value, (int, float)):
        return float(value)
    if isinstance(value, str):
        text = value.strip()
        if text == "":
            return 0.0
        try:
            return float(int(text, 16)) if text.lower().startswith("0x") else float(text)
        except ValueError:
            return math.nan
    return math.nan


def to_string(value):
    if value is None:
        return ""
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, float):
        if math.isnan(value):
            return "NaN"
        return str(int(value)) if value.is_integer() else repr(value)
    if isinstance(value, int):
        return str(value)
    if isinstance(value, list):
        return "Array"
    if isinstance(value, dict):
        return "Object"
    return str(value)


def _kind(value):
    if value is None:
        return "null"
    if isinstance(value, bool):
        return "boolean"
    if isinstance(value, (int, float)):
        return "number"
    if isinstance(value, str):
        return "string"
    return "object"


def loose_equal(a, b):
    ka, kb = _kind(a), _kind(b)
    if ka == kb:
        if ka == "string":
            return a.lower() == b.lower()
        if ka == "number":
            return float(a) == float(b)
        if ka == "object":
            return a is b
        return a == b
    if "object" in (ka, kb):
        return False
    x, y = to_number(a), to_number(b)
    return not (math.isnan(x) or math.isnan(y)) and x == y


def compare(op, a, b):
    if isinstance(a, str) and isinstance(b, str):
        x, y = a.lower(), b.lower()
    else:
        x, y = to_number(a), to_number(b)
        if math.isnan(x) or math.isnan(y):
            return False
    return {"<": x < y, "<=": x <= y, ">": x > y, ">=": x >= y}[op]


def _property(value, name):
    if isinstance(value, Unknown):
        return Unknown(why=f"{value.why}.{name}")
    if isinstance(value, dict):
        for key, item in value.items():          # property names are case-insensitive
            if str(key).lower() == str(name).lower():
                return item
        return Unknown(why=name) if isinstance(value, Partial) else None
    if isinstance(value, list) and isinstance(name, float) and name.is_integer():
        index = int(name)
        return value[index] if 0 <= index < len(value) else None
    return None


# ── evaluation ────────────────────────────────────────────────────────────────
class Evaluator:
    def __init__(self, contexts):
        self.contexts = contexts
        self.resolved = {}            # reference -> value, for the evidence
        self.unknown = set()          # references that could not be resolved
        self.status_functions = set()

    def reference(self, node):
        """The dotted path of a context access, e.g. matrix.os, or None."""
        if node[0] == "context":
            return node[1]
        if node[0] == "property":
            base = self.reference(node[1])
            return f"{base}.{node[2]}" if base else None
        if node[0] == "index" and node[2][0] == "literal":
            base = self.reference(node[1])
            return f"{base}[{node[2][1]!r}]" if base else None
        return None

    def note(self, node, value):
        ref = self.reference(node)
        if ref:
            if isinstance(value, Unknown):
                self.unknown.add(ref)
            else:
                self.resolved[ref] = value

    def eval(self, node):
        kind = node[0]
        if kind == "literal":
            return node[1]
        if kind == "context":
            value = self.contexts.get(node[1].lower(), Unknown(why=node[1]))
            if isinstance(value, Unknown):
                self.note(node, value)
            return value
        if kind in ("property", "index"):
            base = self.eval(node[1])
            key = node[2] if kind == "property" else self.eval(node[2])
            if isinstance(key, Unknown):
                value = Unknown(why="index")
            elif kind == "index" and isinstance(key, str):
                value = _property(base, key)
            else:
                value = _property(base, key)
            self.note(node, value)
            return value
        if kind == "filter":
            base = self.eval(node[1])
            if isinstance(base, Unknown):
                return Unknown(why="filter")
            if isinstance(base, dict):
                return list(base.values())
            return base if isinstance(base, list) else []
        if kind == "not":
            value = self.eval(node[1])
            t = truthy(value)
            return Unknown(truthy=None if t is None else not t, why="!") if isinstance(value, Unknown) else not t
        if kind == "binary":
            return self.binary(node[1], node[2], node[3])
        if kind == "call":
            return self.call(node[1], node[2])
        raise ExpressionError(f"unknown node {kind}")

    def binary(self, op, left, right):
        if op in ("&&", "||"):
            a = self.eval(left)
            ta = truthy(a)
            if op == "&&" and ta is False or op == "||" and ta is True:
                return a                        # short-circuit: the right side is not evaluated
            b = self.eval(right)
            if ta is not None:
                return b                        # a decided nothing: the value is b
            tb = truthy(b)
            if op == "&&":
                return Unknown(truthy=False if tb is False else None, why="&&")
            return Unknown(truthy=True if tb is True else None, why="||")
        a, b = self.eval(left), self.eval(right)
        if isinstance(a, Unknown) or isinstance(b, Unknown):
            return Unknown(why=op)
        if op == "==":
            return loose_equal(a, b)
        if op == "!=":
            return not loose_equal(a, b)
        return compare(op, a, b)

    def call(self, name, args):
        if name in STATUS_FUNCTIONS:
            self.status_functions.add(name)
            if args:
                raise ExpressionError(f"{name}() takes no arguments")
            return True if name == "always" else Unknown(why=f"{name}()")
        values = [self.eval(a) for a in args]
        if any(isinstance(v, Unknown) for v in values):
            return Unknown(why=f"{name}()")
        if name == "contains":
            search, item = values
            if isinstance(search, list):
                return any(loose_equal(element, item) for element in search)
            return to_string(item).lower() in to_string(search).lower()
        if name == "startswith":
            return to_string(values[0]).lower().startswith(to_string(values[1]).lower())
        if name == "endswith":
            return to_string(values[0]).lower().endswith(to_string(values[1]).lower())
        if name == "format":
            return format_string(values[0], values[1:])
        if name == "join":
            separator = to_string(values[1]) if len(values) > 1 else ","
            items = values[0] if isinstance(values[0], list) else [values[0]]
            return separator.join(to_string(v) for v in items)
        if name == "tojson":
            return json.dumps(values[0], indent=2)
        if name == "fromjson":
            try:
                return json.loads(to_string(values[0]))
            except ValueError:
                return Unknown(why="fromJSON() of invalid JSON")
        return Unknown(why=f"{name}()")         # hashFiles and anything else: runtime


def format_string(template, args):
    out, i, text = [], 0, to_string(template)
    while i < len(text):
        if text.startswith("{{", i):
            out.append("{")
            i += 2
        elif text.startswith("}}", i):
            out.append("}")
            i += 2
        elif text[i] == "{":
            end = text.find("}", i)
            index = text[i + 1:end] if end > 0 else ""
            if not index.isdigit() or int(index) >= len(args):
                raise ExpressionError(f"bad format placeholder in {text!r}")
            out.append(to_string(args[int(index)]))
            i = end + 1
        else:
            out.append(text[i])
            i += 1
    return "".join(out)


def evaluate(expression, contexts):
    """(value, evaluator) of one expression; ExpressionError if it does not parse."""
    evaluator = Evaluator(contexts)
    value = evaluator.eval(Parser(expression).parse())
    return value, evaluator


def resolve_condition(condition, contexts):
    """("TRUE" | "FALSE" | "UNKNOWN", evidence) of an `if:` value, as GitHub reads it."""
    if condition is None:
        return TRUE, {"expression": None, "implicit_status": "success()"}
    if isinstance(condition, bool):
        expression = "true" if condition else "false"
    else:
        expression = str(condition)
        wrapped = WRAPPED.match(expression)
        if wrapped:
            expression = wrapped.group(1)
        elif "${{" in expression:
            return UNKNOWN, {"expression": expression, "error": "mixes literal text and ${{ }}"}
    try:
        value, evaluator = evaluate(expression, contexts)
    except (ExpressionError, TypeError, ValueError) as e:
        return UNKNOWN, {"expression": expression, "error": str(e)}
    t = truthy(value)
    result = UNKNOWN if t is None else (TRUE if t else FALSE)

    def deepest(references):        # `matrix.os`, not also `matrix`
        return [r for r in references
                if not any(o != r and (o.startswith(r + ".") or o.startswith(r + "[")) for o in references)]

    resolved = deepest(evaluator.resolved)
    evidence = {"expression": expression.strip(),
                "resolved": {k: evaluator.resolved[k] for k in sorted(resolved)},
                "unknown": sorted(deepest(evaluator.unknown))}
    if not evaluator.status_functions:
        evidence["implicit_status"] = "success()"     # TRUE still needs the earlier steps to succeed
    else:
        evidence["status_functions"] = sorted(evaluator.status_functions)
    return result, evidence
