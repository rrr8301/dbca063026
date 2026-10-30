"""Shell-Aware Dependency Analysis (SADA) for GWA-v3.

A `run:` script becomes a Shell Command IR: one record per simple command,
in execution order, with the program (normalised: `python -m pip` is pip,
`sudo`/`env`/`time` are unwrapped, `bash -c '...'` is parsed in place), its
static arguments, the working directory it runs in, what kind of command it
is, and the files and environments it reads, writes or configures. The
script itself is never changed or run; the IR only describes it.

Front ends, per shell:
  bash / sh   tree-sitter-bash: lists, pipelines, subshells, redirections,
              if / for / while / case bodies (marked `guarded`), functions,
              command substitution, heredocs, prefix assignments
  pwsh        lexical: statements, pipelines, `$env:X =`, Set-Location,
              Push/Pop-Location, redirection, the file cmdlets
  cmd         lexical: `&`, `&&`, `||`, `^` continuation, `set`, `cd /d`,
              `pushd` / `popd`, redirection
  other       (python, node, custom): not parsed -- reported as unsupported

Every dependency has a confidence:
  explicit   the command's arguments name it (`-r reqs.txt`, `> out.txt`,
             `cp a b`, a script path)
  implicit   the program reads it by convention in its working directory
             (`npm ci`: package.json, package-lock.json). The caller keeps
             it only if the file exists or an earlier step writes it
  possible   a heuristic (`gen.py --output data/x.json` may write x.json)
What cannot be known statically is listed as `unresolved`: dynamic
arguments, an unknown working directory, what an arbitrary script reads.
Classification describes a command's effect if it runs; it never implies
that it succeeded.
"""
import os
import re

try:
    import tree_sitter
    import tree_sitter_bash
    _BASH = tree_sitter.Parser(tree_sitter.Language(tree_sitter_bash.language()))
except ImportError:              # reported per script as parsed_by "unavailable"
    _BASH = None

GHA_EXPRESSION = re.compile(r"\$\{\{(.*?)\}\}", re.DOTALL)
PLACEHOLDER = re.compile(r"__GHA_EXPR_(\d+)__")
WORKSPACE = "/__workspace__"     # $GITHUB_WORKSPACE, resolved to the workspace root
HOME = "/__home__"
GITHUB_FILES = {"GITHUB_ENV", "GITHUB_PATH", "GITHUB_OUTPUT", "GITHUB_STEP_SUMMARY", "GITHUB_STATE"}
SPECIAL_FILES = {"/dev/null", "/dev/stdout", "/dev/stderr", "nul", "NUL", "$null"}

KINDS = ("directory_change", "environment_setup", "dependency_installation", "build", "test_execution",
         "static_analysis", "file_generation", "file_operation", "script_execution", "container",
         "version_control", "workflow_command", "output", "condition", "unknown")
CONFIDENCE = ("explicit", "implicit", "possible")

# ── program tables ────────────────────────────────────────────────────────────
WRAPPERS = {   # program: options that take a value; the wrapped command follows
    "sudo": {"-u", "-g", "-C", "-h", "-p"}, "env": {"-u", "-C", "-S"}, "time": set(), "nohup": set(),
    "nice": {"-n"}, "stdbuf": {"-i", "-o", "-e"}, "timeout": {"-s", "-k"}, "command": set(),
    "exec": set(), "xvfb-run": {"-s", "--server-args", "-n", "-f"}, "caffeinate": set(),
    "retry": {"-t", "--times", "-d", "--delay"}, "unbuffer": set(), "chronic": set(),
}
SHELLS = {"bash", "sh", "zsh", "dash", "ksh"}
PYTHON = re.compile(r"^(?:python(?:\d+(?:\.\d+)*)?|py|pypy\d*)(?:\.exe)?$")
RUNNERS = {   # (program, subcommand) whose remaining arguments are another command
    ("poetry", "run"): "python", ("pdm", "run"): "python", ("pipenv", "run"): "python",
    ("uv", "run"): "python", ("hatch", "run"): "python", ("rye", "run"): "python",
    ("conda", "run"): "python", ("mamba", "run"): "python", ("micromamba", "run"): "python",
    ("npx", None): "node", ("pnpx", None): "node", ("bunx", None): "node", ("pnpm", "exec"): "node",
    ("yarn", "exec"): "node", ("bundle", "exec"): "ruby", ("uvx", None): "python", ("pipx", "run"): "python",
}
# ecosystem of the environment a program runs in (what it consumes)
ECOSYSTEM = {
    "python": "python", "pip": "python", "pytest": "python", "tox": "python", "nox": "python",
    "coverage": "python", "mypy": "python", "ruff": "python", "flake8": "python", "black": "python",
    "isort": "python", "pylint": "python", "sphinx-build": "python", "pre-commit": "python",
    "poetry": "python", "uv": "python", "pdm": "python", "pipenv": "python", "hatch": "python",
    "maturin": "python", "twine": "python", "conda": "python", "mamba": "python", "micromamba": "python",
    "node": "node", "npm": "node", "yarn": "node", "pnpm": "node", "bun": "node", "npx": "node",
    "tsc": "node", "jest": "node", "vitest": "node", "mocha": "node", "eslint": "node",
    "prettier": "node", "playwright": "node", "lerna": "node", "nx": "node", "turbo": "node",
    "cargo": "rust", "rustc": "rust", "rustup": "rust", "cross": "rust",
    "go": "go", "gofmt": "go", "golangci-lint": "go",
    "mvn": "java", "mvnw": "java", "gradle": "java", "gradlew": "java", "java": "java", "javac": "java",
    "ant": "java", "sbt": "java",
    "cmake": "system", "ctest": "system", "make": "system", "gmake": "system", "ninja": "system",
    "meson": "system", "gcc": "system", "g++": "system", "clang": "system", "clang++": "system",
    "configure": "system", "autoreconf": "system", "bazel": "system", "bazelisk": "system",
    "conan": "system", "vcpkg": "system", "scons": "system",
    "bundle": "ruby", "gem": "ruby", "rake": "ruby", "ruby": "ruby",
    "dotnet": "dotnet", "msbuild": "dotnet",
}
# ecosystem -> the package-manager names GWA reports (as in gwa.PACKAGE_MANAGER_COMMANDS)
MANAGER = {
    "pip": "pip", "uv": "uv", "poetry": "poetry", "pdm": "pdm", "hatch": "hatch", "tox": "tox",
    "nox": "nox", "conda": "conda", "mamba": "conda", "micromamba": "conda", "npm": "npm",
    "npx": "npm", "yarn": "yarn", "pnpm": "pnpm", "bun": "bun", "mvn": "maven", "mvnw": "maven",
    "gradle": "gradle", "gradlew": "gradle", "cargo": "cargo", "go": "go", "cmake": "cmake",
    "make": "make", "gmake": "make", "meson": "meson", "ninja": "ninja", "bazel": "bazel",
    "bazelisk": "bazel", "apt": "apt", "apt-get": "apt", "brew": "brew", "vcpkg": "vcpkg",
    "conan": "conan", "dotnet": "dotnet",
}
SYSTEM_INSTALL = {"apt": "install", "apt-get": "install", "yum": "install", "dnf": "install",
                  "apk": "add", "brew": "install", "choco": "install", "pacman": "-S", "zypper": "install",
                  "port": "install", "winget": "install", "scoop": "install"}
PYTHON_PROJECT = ("pyproject.toml", "setup.py", "setup.cfg")
PYTEST_CONFIG = ("pytest.ini", "pyproject.toml", "setup.cfg", "tox.ini", "conftest.py")
LINT_CONFIG = {"ruff": ("pyproject.toml", "ruff.toml", ".ruff.toml"), "flake8": (".flake8", "setup.cfg", "tox.ini"),
               "mypy": ("mypy.ini", ".mypy.ini", "pyproject.toml", "setup.cfg"), "black": ("pyproject.toml",),
               "isort": ("pyproject.toml", ".isort.cfg", "setup.cfg"), "pylint": (".pylintrc", "pyproject.toml"),
               "pre-commit": (".pre-commit-config.yaml",), "eslint": ("package.json",),
               "prettier": ("package.json",), "golangci-lint": (".golangci.yml", ".golangci.yaml", "go.mod")}
NODE_LOCKS = {"npm": ("package.json", "package-lock.json", "npm-shrinkwrap.json"),
              "yarn": ("package.json", "yarn.lock", ".yarnrc.yml", ".yarnrc"),
              "pnpm": ("package.json", "pnpm-lock.yaml", "pnpm-workspace.yaml"),
              "bun": ("package.json", "bun.lockb", "bun.lock")}
YARN_BUILTINS = {"install", "add", "remove", "upgrade", "init", "info", "config", "cache", "global",
                 "link", "unlink", "pack", "publish", "set", "dlx", "why", "workspaces", "version", "dedupe"}
CARGO_MANIFEST = ("Cargo.toml", "Cargo.lock", "rust-toolchain.toml", "rust-toolchain", ".cargo/config.toml")
GRADLE_FILES = ("build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts",
                "gradle.properties")
OUTPUT_FLAGS = {"-o", "--output", "--out", "--output-file", "--outfile", "--out-file", "--output-dir",
                "--outdir", "--out-dir", "--dest", "--destination"}
POSSIBLE_PATH = re.compile(r"^[\w.@+-]+(?:/[\w.@+-]*)*\.[A-Za-z0-9]{1,6}$|^[\w.@+-]*/[\w./@+-]*$")


# ── state and records ─────────────────────────────────────────────────────────
class State:
    """What the analysis knows at a point in the script."""

    def __init__(self, cwd=".", variables=None):
        self.cwd = cwd                        # workspace-relative; None when unknown
        self.vars = dict(variables or {})     # name -> literal value, or None when dynamic
        self.dirs = []                        # pushd stack
        self.functions = {}
        self.guarded = False

    def copy(self, guarded=None):
        other = State(self.cwd, self.vars)
        other.dirs, other.functions = list(self.dirs), self.functions
        other.guarded = self.guarded if guarded is None else guarded
        return other

    def join(self, branch):
        """After a branch that may not run: what it changed becomes unknown."""
        if branch.cwd != self.cwd:
            self.cwd = None
        for name, value in branch.vars.items():
            if self.vars.get(name, object()) != value:
                self.vars[name] = None


def resolve_path(state, value):
    """("workspace", relative path) | ("external", value) | (None, reason)."""
    if value is None:
        return None, "dynamic path"
    value = value.strip().replace("\\", "/")
    if not value or value in SPECIAL_FILES:
        return None, "no file"
    if value.startswith(WORKSPACE):
        rel = value[len(WORKSPACE):].lstrip("/") or "."
    elif value.startswith(("~", HOME)) or value.startswith("/") or re.match(r"^[A-Za-z]:/", value):
        return "external", value
    elif state.cwd is None:
        return None, f"relative path {value!r} in an unknown working directory"
    else:
        rel = os.path.join(state.cwd, value)
    rel = os.path.normpath(rel).replace("\\", "/")
    if rel == ".." or rel.startswith("../"):
        return "external", value
    return "workspace", rel


class Analysis:
    def __init__(self, shell, expressions):
        self.shell = shell
        self.expressions = expressions        # placeholder index -> `${{ }}` text
        self.commands = []
        self.unresolved = []
        self.parse_errors = []

    def note(self, text):
        if text not in self.unresolved:
            self.unresolved.append(text)

    def describe(self, value):
        """A value with its `${{ }}` placeholders shown as written."""
        if value is None:
            return None
        return PLACEHOLDER.sub(lambda m: "${{ " + self.expressions[int(m.group(1))] + " }}", value)

    def static(self, value):
        """`value` when it holds no `${{ }}` placeholder; otherwise None (dynamic)."""
        return None if value is None or PLACEHOLDER.search(value) else value

    # ── one simple command ────────────────────────────────────────────────────
    def command(self, state, words, text, line, assignments=None, redirects=(), via=()):
        """Record a simple command: words[0] is the program. Returns the record (or None)."""
        words = [self.static(w) if w is not None else None for w in words]
        if not words:
            return None
        record = {"position": len(self.commands), "line": line, "text": self.describe(text).strip(),
                  "shell": self.shell, "invoked_as": self.describe(words[0]) if words[0] is not None else None,
                  "program": None, "arguments": [self.describe(w) if w is not None else None for w in words[1:]],
                  "cwd": state.cwd, "kind": "unknown", "guarded": state.guarded, "via": list(via),
                  "env": {k: (self.describe(v) if v is not None else None) for k, v in (assignments or {}).items()},
                  "reads": [], "writes": [], "installs": [], "uses": [], "unresolved": []}
        self.commands.append(record)
        if words[0] is None:
            record["unresolved"].append("dynamic program name")
        else:
            self.dispatch(state, record, words)
        for operator, target in redirects:          # after the program: `echo x > f` generates f
            self.redirect(state, record, operator, target)
        return record

    def redirect(self, state, record, operator, target):
        target = self.static(target) if target is not None else None
        if target is None:
            record["unresolved"].append(f"redirection {operator} to a dynamic target")
            return
        github = re.fullmatch(r"\$\{?(\w+)\}?|\$env:(\w+)", target)
        if github and (github.group(1) or github.group(2)) in GITHUB_FILES:
            record["writes_github_file"] = github.group(1) or github.group(2)
            if record["kind"] in ("unknown", "output"):
                record["kind"] = "workflow_command"
            return
        where, path = resolve_path(state, target)
        if where is None:
            if path != "no file":
                record["unresolved"].append(f"redirection target: {path}")
            return
        if where == "external":
            record.setdefault("external", []).append(path)
            return
        if operator.startswith("<"):
            self.read(record, path, "explicit", f"input redirection {operator}")
        else:
            self.write(record, path, "explicit", f"output redirection {operator}")
            if record["kind"] in ("unknown", "output"):
                record["kind"] = "file_generation"

    @staticmethod
    def read(record, path, confidence, why, directory=False):
        if not any(r["path"] == path and r["confidence"] == confidence for r in record["reads"]):
            record["reads"].append({"path": path, "confidence": confidence, "why": why,
                                    **({"directory": True} if directory else {})})

    @staticmethod
    def write(record, path, confidence, why, directory=False):
        if not any(w["path"] == path for w in record["writes"]):
            record["writes"].append({"path": path, "confidence": confidence, "why": why,
                                     **({"directory": True} if directory else {})})

    def read_arg(self, state, record, value, confidence, why, directory=False):
        where, path = resolve_path(state, value)
        if where == "workspace":
            if any(c in path for c in "*?["):
                record["unresolved"].append(f"glob {path!r} ({why})")
            else:
                self.read(record, path, confidence, why, directory)
        elif where == "external":
            record.setdefault("external", []).append(path)
        elif path not in ("no file",):
            record["unresolved"].append(f"{why}: {path}" if value is not None else f"{why}: dynamic argument")

    def write_arg(self, state, record, value, confidence, why, directory=False):
        github = re.fullmatch(r"\$\{?(?:env:)?(\w+)\}?", value or "")
        if github and github.group(1) in GITHUB_FILES:
            record["writes_github_file"] = github.group(1)
            if record["kind"] in ("unknown", "output", "file_generation"):
                record["kind"] = "workflow_command"
            return
        where, path = resolve_path(state, value)
        if where == "workspace":
            if any(c in path for c in "*?["):
                record["unresolved"].append(f"glob {path!r} ({why})")
            else:
                self.write(record, path, confidence, why, directory)
        elif where == "external":
            record.setdefault("external", []).append(path)
        elif path not in ("no file",):
            record["unresolved"].append(f"{why}: {path}" if value is not None else f"{why}: dynamic argument")

    def implicit(self, state, record, names, why, directory=None, upward=True):
        """Files the program reads by convention in `directory` (default: its cwd). With
        `upward`, the program looks for them from there up to the workspace root
        (cargo, go, npm, pytest, ...); the caller links the nearest that exists."""
        base = state.cwd if directory is None else directory
        if base is None:
            record["unresolved"].append(f"{why}: unknown working directory")
            return
        for name in names:
            path = os.path.normpath(os.path.join(base, name)).replace("\\", "/")
            self.read(record, path, "implicit", why)
            if upward:
                read = next(r for r in record["reads"] if r["path"] == path and r["confidence"] == "implicit")
                read.update(search="upward", name=name, base=os.path.normpath(base))

    def project_dir(self, state, value):
        """Workspace-relative directory named by an option such as `-C dir`; None if not static."""
        where, path = resolve_path(state, value)
        return path if where == "workspace" else None

    # ── program semantics ─────────────────────────────────────────────────────
    def dispatch(self, state, record, words, depth=0):
        program, args = words[0], words[1:]
        if program is None:                              # sudo "$TOOL" ...
            record["unresolved"].append("dynamic program name")
            return None
        base = re.sub(r"\.(?:exe|cmd|bat|ps1)$", "", program.replace("\\", "/").rsplit("/", 1)[-1])
        if base in WRAPPERS and args and depth < 5:
            values, rest = WRAPPERS[base], list(args)
            while rest and (rest[0] is None and base == "env" and any(a is not None for a in rest[1:])
                            or rest[0] is not None and (rest[0].startswith("-") or
                                                        (base == "env" and "=" in rest[0]))):
                flag = rest.pop(0)
                if flag is None:
                    record["unresolved"].append("env: a dynamic variable assignment")
                    continue
                if base == "env" and "=" in flag and not flag.startswith("-"):
                    name, _, value = flag.partition("=")
                    record["env"][name] = self.describe(value)
                elif flag in values and rest:
                    rest.pop(0)
            if base == "timeout" and rest:
                rest.pop(0)                              # the duration
            if rest:
                record["via"].append(base)
                return self.dispatch(state, record, rest, depth + 1)
        if base in SHELLS:
            return self.nested_shell(state, record, base, args, depth)
        if base == "xargs":
            record["via"].append("xargs")
            record["unresolved"].append("xargs: arguments come from standard input")
            rest = list(args)
            while rest and rest[0] is not None and rest[0].startswith("-"):
                flag = rest.pop(0)
                if flag in ("-I", "-i", "-n", "-P", "-L", "-d", "-s", "-E", "-a", "--max-args",
                            "--max-procs", "--delimiter", "--arg-file") and rest:
                    rest.pop(0)
            if rest:
                return self.dispatch(state, record, rest, depth + 1)
        if PYTHON.match(base):
            return self.python(state, record, base, args, depth)
        for (runner, sub), ecosystem in RUNNERS.items():
            if base == runner and (sub is None or (args and args[0] == sub)):
                inner = [a for a in (args if sub is None else args[1:])]
                while inner and inner[0] is not None and inner[0].startswith("-"):
                    flag = inner.pop(0)
                    if flag in ("-n", "--name", "-p", "--prefix", "--package", "--from", "-e",
                                "--env", "--with") and inner:
                        inner.pop(0)
                record["via"].append(f"{runner} {sub}" if sub else runner)
                self.use(record, ecosystem)
                if inner:
                    return self.dispatch(state, record, inner, depth + 1)
                return None
        record["program"] = base
        if re.search(r"[/\\]", program) and base not in ("gradlew", "mvnw"):
            self.script(state, record, program, args)        # a script run by path, not a program
            return None
        if base in ("[", "[[", "test"):
            record["kind"] = "condition"
            return None
        handler = self.p_source if base == "." else getattr(self, "p_" + re.sub(r"[^A-Za-z0-9]", "_", base), None)
        if handler is not None:
            handler(state, record, args)
        elif base in SYSTEM_INSTALL and args and SYSTEM_INSTALL[base] in args:
            record["kind"] = "dependency_installation"
            record["installs"].append({"ecosystem": "system", "manager": base,
                                       "packages": [a for a in args if a and not a.startswith("-")
                                                    and a != SYSTEM_INSTALL[base]]})
        else:
            self.generic(state, record, base, args)
        if base in ECOSYSTEM:
            self.use(record, ECOSYSTEM[base])
        if any(a in ("--help", "-h", "--version", "-V", "help") for a in args[:2] if a is not None):
            record["kind"] = "output"                    # `ruff --help`, `cargo --version`
            record["reads"] = [r for r in record["reads"] if r["confidence"] == "explicit"]
            record["writes"], record["installs"] = [], []
        return None

    def use(self, record, ecosystem):
        if ecosystem not in record["uses"]:
            record["uses"].append(ecosystem)

    def install(self, record, ecosystem, manager, **extra):
        record["kind"] = "dependency_installation"
        record["installs"].append({"ecosystem": ecosystem, "manager": manager, **extra})

    def generic(self, state, record, base, args):
        """A program with no table entry: only `-o FILE`-style outputs, as possible writes."""
        if base in ("echo", "printf", "true", ":", "date", "pwd", "whoami", "uname", "nproc", "which",
                    "ls", "df", "free", "sleep", "exit", "set", "shopt", "trap", "env", "printenv",
                    "Write-Host", "Write-Output"):
            record["kind"] = "output"
            return
        self.possible_outputs(state, record, args)
        if base in ECOSYSTEM:
            record["kind"] = "build"
        record["unresolved"].append(f"{base}: effects not modelled")

    def possible_outputs(self, state, record, args):
        for i, arg in enumerate(args):
            if arg is None:
                continue
            flag, eq, value = arg.partition("=")
            if flag in OUTPUT_FLAGS:
                target = value if eq else (args[i + 1] if i + 1 < len(args) else None)
                if target is not None and not target.startswith("-"):
                    self.write_arg(state, record, target, "possible", f"{flag} option")

    def script(self, state, record, path, args):
        """Running a script file: it is read; what it reads in turn is unknown."""
        record["kind"] = "script_execution"
        if path is None:
            record["unresolved"].append("script with a dynamic path")
            return
        record["program"] = path.replace("\\", "/").rsplit("/", 1)[-1]
        self.read_arg(state, record, path, "explicit", "script executed")
        self.possible_outputs(state, record, args)
        record["unresolved"].append(f"what {record['program']} reads and writes")
        if record["program"] in ("configure", "autogen.sh", "bootstrap", "bootstrap.sh"):
            record["kind"] = "build"
            self.implicit(state, record, ("configure.ac", "Makefile.am", "Makefile.in"), "autotools input", upward=False)
            if state.cwd is not None:
                self.write(record, os.path.normpath(os.path.join(state.cwd, "Makefile")), "possible",
                           "configure output")

    def nested_shell(self, state, record, base, args, depth):
        record["program"] = base
        i = 0
        while i < len(args) and args[i] is not None and args[i].startswith("-") and args[i] != "-c":
            i += 1 + (args[i] in ("-o", "+o", "-O"))
        if i < len(args) and args[i] == "-c":
            code = args[i + 1] if i + 1 < len(args) else None
            if code is None:
                record["kind"] = "unknown"
                record["unresolved"].append(f"{base} -c with a dynamic script")
                return
            record["kind"] = "script_execution"
            record["inline"] = True
            nested = state.copy()
            # the nested script's commands follow this record, marked by where they came from
            before = len(self.commands)
            self.bash(code, nested, via=record["via"] + [f"{base} -c"], depth=depth + 1)
            record["nested_commands"] = len(self.commands) - before
            return
        if i < len(args):
            self.script(state, record, args[i], args[i + 1:])
            record["program"] = base
        else:
            record["kind"] = "unknown"
            record["unresolved"].append(f"{base} reads its script from standard input")

    def python(self, state, record, base, args, depth):
        rest = list(args)
        while rest and rest[0] is not None and rest[0].startswith("-") and rest[0] not in ("-m", "-c"):
            rest.pop(0)
        self.use(record, "python")
        if rest[:1] == ["-m"] and len(rest) > 1 and rest[1] is not None:
            module = rest[1]
            record["via"].append(f"{base} -m")
            if module == "venv" or module == "virtualenv":
                record["program"], record["kind"] = module, "environment_setup"
                target = next((a for a in rest[2:] if a is None or not a.startswith("-")), None)
                self.write_arg(state, record, target, "explicit", "virtual environment", directory=True)
                return
            return self.dispatch(state, record, [module] + rest[2:], depth + 1)
        record["program"] = "python"
        if rest[:1] == ["-c"]:
            record["kind"], record["inline"] = "script_execution", True
            record["unresolved"].append("python -c: what the inline code reads and writes")
            return
        if rest and rest[0] is not None:
            self.script(state, record, rest[0], rest[1:])
            record["program"] = "python"
            if os.path.basename(rest[0]) == "setup.py":
                record["kind"] = "build"
            return
        record["kind"] = "unknown"
        record["unresolved"].append("python with a dynamic or missing script")

    # bash / sh: `source` and `.` change this shell's environment
    def p_source(self, state, record, args):
        record["kind"] = "environment_setup"
        if args:
            self.read_arg(state, record, args[0], "explicit", "sourced file")
            if args[0] and "activate" in args[0]:
                self.use(record, "python")
        record["unresolved"].append("variables the sourced file sets")

    def p_export(self, state, record, args):
        record["kind"] = "environment_setup"

    # ── directory changes (state updated by the front ends) ───────────────────
    def p_cd(self, state, record, args):
        record["kind"] = "directory_change"
        target = next((a for a in args if a is None or not (a.startswith("-") or a.lower() == "/d")), "~")
        self.change_directory(state, record, target)

    p_chdir = p_Set_Location = p_sl = p_cd

    def change_directory(self, state, record, target):
        if target == "-":
            state.cwd = None
        else:
            where, path = resolve_path(state, target)
            state.cwd = path if where == "workspace" else None
            if where != "workspace":
                record["unresolved"].append(f"cd to {path if where else 'a dynamic directory'}: "
                                            "later relative paths are unresolved")
        record["cwd_after"] = state.cwd

    def p_pushd(self, state, record, args):
        state.dirs.append(state.cwd)
        record["kind"] = "directory_change"
        target = next((a for a in args if a is None or not a.startswith("-")), None)
        if target is not None or not args:
            self.change_directory(state, record, target if args else "~")
        else:
            self.change_directory(state, record, None)

    p_Push_Location = p_pushd

    def p_popd(self, state, record, args):
        record["kind"] = "directory_change"
        state.cwd = state.dirs.pop() if state.dirs else None
        record["cwd_after"] = state.cwd

    p_Pop_Location = p_popd

    # ── file operations ───────────────────────────────────────────────────────
    def operands(self, args, values=()):
        out, skip = [], False
        for i, a in enumerate(args):
            if skip:
                skip = False
                continue
            if a is not None and ((a.startswith("-") and a != "-") or
                                  (self.shell == "cmd" and re.fullmatch(r"/[A-Za-z?]+", a))):
                skip = a in values
                continue
            out.append(a)
        return out

    def p_cp(self, state, record, args):
        files = self.operands(args, {"-t", "--target-directory", "-S", "--suffix"})
        record["kind"] = "file_operation"
        directory = any(a and re.match(r"^-[a-zA-Z]*[rRa]", a) for a in args)
        if len(files) >= 2:
            for source in files[:-1]:
                self.read_arg(state, record, source, "explicit", "copy source", directory)
            self.write_arg(state, record, files[-1], "explicit", "copy destination", directory)

    p_rsync = p_Copy_Item = p_copy = p_xcopy = p_cp

    def p_mv(self, state, record, args):
        self.p_cp(state, record, args)
        for r in record["reads"]:
            r["why"] = "move source"
        for w in record["writes"]:
            w["why"] = "move destination"

    p_Move_Item = p_move = p_mv

    def p_ln(self, state, record, args):
        files = self.operands(args)
        record["kind"] = "file_operation"
        if len(files) >= 2:
            self.write_arg(state, record, files[-1], "explicit", "link")

    def p_touch(self, state, record, args):
        record["kind"] = "file_generation"
        for f in self.operands(args):
            self.write_arg(state, record, f, "explicit", "created file")

    def p_mkdir(self, state, record, args):
        record["kind"] = "file_generation"
        for f in self.operands(args, {"-m", "--mode"}):
            self.write_arg(state, record, f, "explicit", "created directory", directory=True)

    p_md = p_mkdir

    def p_New_Item(self, state, record, args):
        options = self.options(args, {"-Path", "-ItemType", "-Name", "-Value", "-Type"})
        record["kind"] = "file_generation"
        for path in options.get("-Path", []) + options["_"][:1]:
            directory = any((v or "").lower() == "directory" for v in options.get("-ItemType", []) +
                            options.get("-Type", []))
            self.write_arg(state, record, path, "explicit", "created item", directory)

    def p_rm(self, state, record, args):
        record["kind"] = "file_operation"
        record["removes"] = [self.describe(a) for a in self.operands(args)]

    p_Remove_Item = p_del = p_rmdir = p_rm

    def p_tee(self, state, record, args):
        record["kind"] = "file_generation"
        for f in self.operands(args):
            self.write_arg(state, record, f, "explicit", "tee output")

    def p_Out_File(self, state, record, args):
        options = self.options(args, {"-FilePath", "-Path", "-Encoding"})
        record["kind"] = "file_generation"
        for path in options.get("-FilePath", []) + options.get("-Path", []) + options["_"][:1]:
            self.write_arg(state, record, path, "explicit", "Out-File")

    p_Set_Content = p_Add_Content = p_Out_File

    def p_cat(self, state, record, args):
        record["kind"] = "output"
        for f in self.operands(args):
            self.read_arg(state, record, f, "explicit", "file read")

    p_type = p_Get_Content = p_head = p_tail = p_sha256sum = p_md5sum = p_wc = p_cat

    def p_sed(self, state, record, args):
        in_place = any(a and (a == "-i" or a.startswith("-i") or a.startswith("--in-place")) for a in args)
        files = self.operands(args, {"-e", "-f", "--expression", "--file"})
        if any(a in ("-e", "--expression") for a in args) is False and files:
            files = files[1:]                  # the first operand is the script
        record["kind"] = "file_operation" if in_place else "output"
        for f in files:
            self.read_arg(state, record, f, "explicit", "sed input")
            if in_place:
                self.write_arg(state, record, f, "explicit", "edited in place")

    def p_chmod(self, state, record, args):
        record["kind"] = "file_operation"
        for f in self.operands(args)[1:]:
            self.read_arg(state, record, f, "explicit", "mode changed")

    def p_curl(self, state, record, args):
        record["kind"] = "file_generation"
        options = self.options(args, {"-o", "--output", "-H", "--header", "-d", "--data", "-u", "-X",
                                      "--retry", "-w", "--connect-timeout", "-m", "--max-time", "-A"})
        for target in options.get("-o", []) + options.get("--output", []):
            self.write_arg(state, record, target, "explicit", "download")
        if "-O" in args or "--remote-name" in args:
            record["unresolved"].append("curl -O: file named after the URL")
        if not record["writes"] and "-O" not in args:
            record["kind"] = "output"

    def p_wget(self, state, record, args):
        record["kind"] = "file_generation"
        options = self.options(args, {"-O", "--output-document", "-P", "--directory-prefix"})
        for target in options.get("-O", []) + options.get("--output-document", []):
            self.write_arg(state, record, target, "explicit", "download")
        for target in options.get("-P", []) + options.get("--directory-prefix", []):
            self.write_arg(state, record, target, "explicit", "download directory", directory=True)
        if not record["writes"]:
            record["unresolved"].append("wget: file named after the URL")

    def p_Invoke_WebRequest(self, state, record, args):
        options = self.options(args, {"-Uri", "-OutFile", "-Method", "-Headers"})
        record["kind"] = "file_generation" if options.get("-OutFile") else "output"
        for target in options.get("-OutFile", []):
            self.write_arg(state, record, target, "explicit", "download")

    p_iwr = p_Invoke_WebRequest

    def p_tar(self, state, record, args):
        record["kind"] = "file_operation"
        flags = "".join(a for a in args[:1] if a and not a.startswith("-")) + \
            "".join(a.lstrip("-") for a in args if a and a.startswith("-") and not a.startswith("--"))
        options = self.options(args, {"-f", "--file", "-C", "--directory"})
        archives = options.get("-f", []) + options.get("--file", [])
        if not archives and args and args[0] and not args[0].startswith("-") and "f" in args[0]:
            archives = args[1:2]
        directory = (options.get("-C") or options.get("--directory") or ["."])[0]
        if "x" in flags or "--extract" in args:
            for archive in archives:
                self.read_arg(state, record, archive, "explicit", "archive extracted")
            self.write_arg(state, record, directory, "explicit", "extraction directory", directory=True)
        elif "c" in flags or "--create" in args:
            for archive in archives:
                self.write_arg(state, record, archive, "explicit", "archive created")

    def p_unzip(self, state, record, args):
        record["kind"] = "file_operation"
        options = self.options(args, {"-d", "-x"})
        if options["_"]:
            self.read_arg(state, record, options["_"][0], "explicit", "archive extracted")
        self.write_arg(state, record, (options.get("-d") or ["."])[0], "explicit", "extraction directory",
                       directory=True)

    def p_Expand_Archive(self, state, record, args):
        options = self.options(args, {"-Path", "-LiteralPath", "-DestinationPath"})
        record["kind"] = "file_operation"
        for path in options.get("-Path", []) + options.get("-LiteralPath", []) + options["_"][:1]:
            self.read_arg(state, record, path, "explicit", "archive extracted")
        for path in options.get("-DestinationPath", []) + options["_"][1:2]:
            self.write_arg(state, record, path, "explicit", "extraction directory", directory=True)

    def p_git(self, state, record, args):
        record["kind"] = "version_control"
        operands = self.operands(args, {"-C", "-c", "--depth", "-b", "--branch", "-o"})
        if operands[:1] == ["clone"] and len(operands) >= 3:
            self.write_arg(state, record, operands[2], "explicit", "clone destination", directory=True)
        elif operands[:2] == ["submodule", "update"]:
            record["unresolved"].append("git submodule update: submodule paths from .gitmodules")
            self.implicit(state, record, (".gitmodules",), "git submodule")
        elif operands[:1] == ["apply"]:
            for patch in operands[1:]:
                self.read_arg(state, record, patch, "explicit", "patch applied")

    def p_docker(self, state, record, args):
        record["kind"] = "container"
        operands = self.operands(args, {"-f", "--file", "-t", "--tag", "--build-arg", "-v", "-e", "-p",
                                        "--name", "--platform", "--target", "-w", "--network"})
        options = self.options(args, {"-f", "--file"})
        if operands[:1] == ["build"] or operands[:2] == ["buildx", "build"]:
            record["kind"] = "build"
            context = operands[-1] if len(operands) > 1 else "."
            files = options.get("-f", []) + options.get("--file", [])
            for f in files:
                self.read_arg(state, record, f, "explicit", "Dockerfile")
            if not files:
                where, path = resolve_path(state, context)
                if where == "workspace":
                    self.read(record, os.path.normpath(os.path.join(path, "Dockerfile")), "implicit", "Dockerfile")
            self.read_arg(state, record, context, "explicit", "build context", directory=True)
        elif operands[:1] == ["compose"] or record["program"] == "docker-compose":
            files = options.get("-f", []) + options.get("--file", [])
            for f in files:
                self.read_arg(state, record, f, "explicit", "compose file")
            if not files:
                self.implicit(state, record, ("docker-compose.yml", "compose.yaml", "docker-compose.yaml"),
                              "compose file", upward=False)

    p_docker_compose = p_docker

    # ── Python ────────────────────────────────────────────────────────────────
    @staticmethod
    def options(args, values):
        """{option: [values]} for options that take a value; "_": the operands."""
        out, i = {"_": []}, 0
        while i < len(args):
            a = args[i]
            if a is None:
                out["_"].append(None)
            elif "=" in a and a.split("=", 1)[0] in values:
                key, value = a.split("=", 1)
                out.setdefault(key, []).append(value)
            elif a in values:
                out.setdefault(a, []).append(args[i + 1] if i + 1 < len(args) else None)
                i += 1
            elif len(a) > 2 and a[:2] in values and not a.startswith("--"):
                out.setdefault(a[:2], []).append(a[2:])         # -rrequirements.txt
            elif a.startswith("-") and a != "-":
                out.setdefault(a, [])
            else:
                out["_"].append(a)
            i += 1
        return out

    def python_project(self, state, record, target, why, confidence="explicit"):
        """A local project directory (`pip install -e .`): its packaging metadata is read."""
        where, path = resolve_path(state, re.sub(r"\[[^\]]*\]$", "", target) if target else target)
        if where == "workspace":
            self.read(record, path, confidence, why, directory=True)
            for name in PYTHON_PROJECT:
                self.read(record, os.path.normpath(os.path.join(path, name)), "implicit", f"{why}: packaging metadata")
        elif where is None:
            record["unresolved"].append(f"{why}: {path}")

    def p_pip(self, state, record, args):
        options = self.options(args, {"-r", "--requirement", "-c", "--constraint", "-e", "--editable",
                                      "-t", "--target", "--prefix", "-i", "--index-url", "--extra-index-url",
                                      "-f", "--find-links", "--root", "--python", "-w", "--wheel-dir"})
        sub = next((a for a in options["_"]), None)
        operands = options["_"][1:]
        for key in ("-r", "--requirement", "-c", "--constraint"):
            for f in options.get(key, []):
                self.read_arg(state, record, f, "explicit", f"pip {key}")
        if sub in ("install", "download", "wheel", "sync"):
            if sub in ("install", "sync"):
                self.install(record, "python", "pip")
            else:
                record["kind"] = "dependency_installation"
            for target in options.get("-e", []) + options.get("--editable", []):
                self.python_project(state, record, target, "editable install")
            for target in operands:
                if target is None:
                    record["unresolved"].append("pip: dynamic requirement")
                elif target in (".", "..") or target.startswith(("./", "../", "/")) or \
                        re.match(r"^\.\[", target) or (("/" in target or "\\" in target) and "://" not in target
                                                       and "@" not in target and not target.endswith((".whl", ".tar.gz", ".zip"))):
                    self.python_project(state, record, target, "local project install")
                elif target.endswith((".whl", ".tar.gz", ".zip")) and "://" not in target:
                    self.read_arg(state, record, target, "explicit", "package file")
            for key in ("-w", "--wheel-dir", "-t", "--target"):
                for target in options.get(key, []):
                    self.write_arg(state, record, target, "explicit", f"pip {key}", directory=True)
        elif sub == "uninstall":
            record["kind"] = "environment_setup"
        elif sub in ("freeze", "list", "show", "check", "--version", "config", "cache", "debug", None):
            record["kind"] = "output"
        elif sub == "compile":                     # uv pip compile
            record["kind"] = "dependency_installation"
            for f in operands:
                self.read_arg(state, record, f, "explicit", "requirements input")
            for target in self.options(args, {"-o", "--output-file"}).get("-o", []):
                self.write_arg(state, record, target, "explicit", "compiled requirements")

    p_pip3 = p_pip

    def p_pip_sync(self, state, record, args):
        self.install(record, "python", "pip")
        for f in self.operands(args) or ["requirements.txt"]:
            self.read_arg(state, record, f, "explicit", "pip-sync requirements")

    def p_pip_compile(self, state, record, args):
        record["kind"] = "dependency_installation"
        options = self.options(args, {"-o", "--output-file"})
        for f in options["_"]:
            self.read_arg(state, record, f, "explicit", "requirements input")
        for f in options.get("-o", []) + options.get("--output-file", []):
            self.write_arg(state, record, f, "explicit", "compiled requirements")

    def p_uv(self, state, record, args):
        options = self.options(args, {"--directory", "--project", "-p", "--python", "--extra", "--group",
                                      "--package", "-r", "--requirements"})
        sub = (options["_"] or [None])[0]
        directory = self.project_dir(state, (options.get("--directory") or options.get("--project") or [None])[0]) \
            if options.get("--directory") or options.get("--project") else state.cwd
        if sub == "pip":
            return self.p_pip(state, record, args[args.index("pip") + 1:])
        if sub in ("sync", "lock", "add", "remove"):
            self.install(record, "python", "uv")
            self.implicit(state, record, ("pyproject.toml", "uv.lock"), f"uv {sub}", directory)
        elif sub == "venv":
            record["kind"] = "environment_setup"
            target = next((a for a in options["_"][1:]), ".venv")
            self.write_arg(state, record, target, "explicit", "virtual environment", directory=True)
        elif sub == "build":
            record["kind"] = "build"
            self.implicit(state, record, PYTHON_PROJECT, "uv build", directory)
            if directory is not None:
                self.write(record, os.path.normpath(os.path.join(directory, "dist")), "implicit",
                           "uv build output", True)
        elif sub in ("tool", "python"):
            self.install(record, "python", "uv")
        else:
            record["kind"] = "unknown"

    def p_poetry(self, state, record, args):
        options = self.options(args, {"-C", "--directory", "--with", "--without", "--only", "-E", "--extras"})
        sub = (options["_"] or [None])[0]
        directory = self.project_dir(state, (options.get("-C") or options.get("--directory"))[0]) \
            if options.get("-C") or options.get("--directory") else state.cwd
        if sub in ("install", "sync", "update", "add", "remove", "lock"):
            self.install(record, "python", "poetry")
            self.implicit(state, record, ("pyproject.toml", "poetry.lock"), f"poetry {sub}", directory)
        elif sub == "build":
            record["kind"] = "build"
            self.implicit(state, record, ("pyproject.toml",), "poetry build", directory)
        elif sub in ("config", "self", "env", "version", "--version", "check"):
            record["kind"] = "environment_setup"

    def p_pdm(self, state, record, args):
        sub = (self.operands(args) or [None])[0]
        if sub in ("install", "sync", "add", "update", "lock"):
            self.install(record, "python", "pdm")
            self.implicit(state, record, ("pyproject.toml", "pdm.lock"), f"pdm {sub}")

    def p_pipenv(self, state, record, args):
        sub = (self.operands(args) or [None])[0]
        if sub in ("install", "sync", "update", "lock"):
            self.install(record, "python", "pipenv")
            self.implicit(state, record, ("Pipfile", "Pipfile.lock"), f"pipenv {sub}")

    def p_hatch(self, state, record, args):
        sub = (self.operands(args) or [None])[0]
        record["kind"] = {"build": "build", "test": "test_execution", "env": "environment_setup"}.get(sub, "unknown")
        self.implicit(state, record, ("pyproject.toml", "hatch.toml"), f"hatch {sub}")

    def p_conda(self, state, record, args):
        options = self.options(args, {"-f", "--file", "-n", "--name", "-p", "--prefix", "-c", "--channel"})
        operands = options["_"]
        files = options.get("-f", []) + options.get("--file", [])
        if operands[:1] in (["install"], ["create"], ["update"]) or operands[:2] in (["env", "create"],
                                                                                   ["env", "update"]):
            self.install(record, "python", record["program"])
            for f in files:
                self.read_arg(state, record, f, "explicit", "environment file")
            if operands[:1] == ["env"] and not files:
                self.implicit(state, record, ("environment.yml",), "conda env", upward=False)
        elif operands[:1] in (["activate"], ["init"], ["config"]):
            record["kind"] = "environment_setup"

    p_mamba = p_micromamba = p_conda

    def p_pytest(self, state, record, args):
        record["kind"] = "test_execution"
        options = self.options(args, {"-c", "-k", "-m", "-p", "-n", "--rootdir", "--junitxml", "--junit-xml",
                                      "--cov", "--cov-report", "--cov-config", "--basetemp", "-o",
                                      "--ignore", "--deselect", "--confcutdir", "--durations", "--maxfail",
                                      "--timeout", "-W", "--tb", "--log-level", "--import-mode",
                                      "--html", "--reruns", "--dist"})
        for f in options.get("-c", []):
            self.read_arg(state, record, f, "explicit", "pytest configuration")
        if not options.get("-c"):
            self.implicit(state, record, PYTEST_CONFIG, "pytest configuration")
        for target in options["_"]:
            if target is not None and "::" in target:
                target = target.split("::", 1)[0]
            self.read_arg(state, record, target, "explicit", "test path", directory=True)
        for key in ("--junitxml", "--junit-xml", "--html"):
            for f in options.get(key, []):
                self.write_arg(state, record, f, "explicit", "test report")
        record["unresolved"].append("data the tests read at run time")

    p_py_test = p_pytest

    def p_unittest(self, state, record, args):
        record["kind"] = "test_execution"
        record["unresolved"].append("data the tests read at run time")

    def p_tox(self, state, record, args):
        record["kind"] = "test_execution"
        options = self.options(args, {"-c", "-e", "--conf", "-p", "--workdir", "-m"})
        files = options.get("-c", []) + options.get("--conf", [])
        for f in files:
            self.read_arg(state, record, f, "explicit", "tox configuration")
        if not files:
            self.implicit(state, record, ("tox.ini", "pyproject.toml", "setup.cfg"), "tox configuration")
        self.implicit(state, record, PYTHON_PROJECT, "package tox installs")
        record["installs"].append({"ecosystem": "python", "manager": "tox", "isolated": True})

    def p_nox(self, state, record, args):
        record["kind"] = "test_execution"
        options = self.options(args, {"-f", "--noxfile", "-s", "--session", "-p", "--python"})
        files = options.get("-f", []) + options.get("--noxfile", [])
        for f in files:
            self.read_arg(state, record, f, "explicit", "noxfile")
        if not files:
            self.implicit(state, record, ("noxfile.py",), "noxfile")

    def p_coverage(self, state, record, args):
        operands = self.operands(args, {"--rcfile", "--source", "--omit", "--include", "-o"})
        if operands[:1] == ["run"]:
            record["via"].append("coverage run")
            rest = args[args.index("run") + 1:]
            while rest and rest[0] is not None and rest[0].startswith("-"):
                rest.pop(0)
            if rest[:1] == ["-m"] and len(rest) > 1:
                return self.dispatch(state, record, rest[1:])
            if rest:
                return self.python(state, record, "python", rest, 0)
        record["kind"] = "output"
        self.implicit(state, record, (".coveragerc", "pyproject.toml", "setup.cfg"), "coverage configuration")

    def lint(self, state, record, args):
        record["kind"] = "static_analysis"
        self.implicit(state, record, LINT_CONFIG.get(record["program"], ()), f"{record['program']} configuration")
        for target in self.operands(args, {"--config", "-c", "--select", "--ignore", "--output-format",
                                           "--max-line-length", "--rcfile", "--format", "-f"}):
            if target not in ("check", "format", "run", "--fix"):
                self.read_arg(state, record, target, "explicit", "checked path", directory=True)

    p_ruff = p_flake8 = p_mypy = p_black = p_isort = p_pylint = p_golangci_lint = p_lint = lint

    def p_pre_commit(self, state, record, args):
        record["kind"] = "static_analysis"
        self.implicit(state, record, (".pre-commit-config.yaml",), "pre-commit configuration")

    def p_build(self, state, record, args):          # python -m build
        record["kind"] = "build"
        target = next((a for a in self.operands(args, {"-o", "--outdir"})), ".")
        self.python_project(state, record, target, "built project")
        outdir = (self.options(args, {"-o", "--outdir"}).get("-o") or ["dist"])[0]
        self.write_arg(state, record, outdir, "implicit" if outdir == "dist" else "explicit", "build output", True)

    def p_maturin(self, state, record, args):
        record["kind"] = "build"
        self.implicit(state, record, ("pyproject.toml", "Cargo.toml"), "maturin project")
        self.use(record, "rust")

    def p_sphinx_build(self, state, record, args):
        record["kind"] = "build"
        operands = self.operands(args, {"-b", "-c", "-d", "-D", "-j", "-w", "-t"})
        if operands:
            self.read_arg(state, record, operands[0], "explicit", "documentation source", directory=True)
        if len(operands) > 1:
            self.write_arg(state, record, operands[1], "explicit", "documentation output", directory=True)

    # ── JavaScript / TypeScript ───────────────────────────────────────────────
    def node_manager(self, state, record, args, manager):
        options = self.options(args, {"--prefix", "-C", "--dir", "--cwd", "-w", "--workspace", "--filter", "-F"})
        operands = [a for a in options["_"]]
        key = next((k for k in ("--prefix", "-C", "--dir", "--cwd") if options.get(k)), None)
        directory = self.project_dir(state, options[key][0]) if key else state.cwd
        if key and directory is None:
            record["unresolved"].append(f"{manager} {key}: dynamic directory")
        sub = operands[0] if operands else None
        if options.get("--filter") or options.get("-F") or options.get("-w") or options.get("--workspace"):
            record["unresolved"].append(f"{manager}: workspace filter selects packages at run time")
        installs = {"npm": ("ci", "install", "i", "add", "update", "rebuild"),
                    "yarn": (None, "install", "add"), "pnpm": ("install", "i", "add", "update", "fetch"),
                    "bun": ("install", "i", "add")}[manager]
        if sub in installs or (manager == "yarn" and sub is None):
            global_install = "-g" in args or "--global" in args
            self.install(record, "node", manager, **({"global": True} if global_install else {}))
            if not global_install or len(operands) == 1:    # `npm install -g`: the package in the cwd
                self.implicit(state, record, NODE_LOCKS[manager], f"{manager} {sub or 'install'}", directory)
                if directory is not None:
                    self.write(record, os.path.normpath(os.path.join(directory, "node_modules")), "implicit",
                               f"{manager} installs packages", True)
            return
        script = None
        if sub in ("run", "run-script") and len(operands) > 1:
            script = operands[1]
        elif sub in ("test", "t", "start", "build") or (manager in ("yarn", "pnpm", "bun") and sub is not None
                                                       and sub not in YARN_BUILTINS and sub != "exec"):
            script = "test" if sub == "t" else sub
        if script is not None:
            record["script"] = script
            record["kind"] = ("test_execution" if script and re.search(r"test|spec|e2e|coverage", script)
                              else "build" if script and re.search(r"build|compile|dist|bundle|tsc", script)
                              else "static_analysis" if script and re.search(r"lint|format|check|typecheck", script)
                              else "script_execution")
            self.implicit(state, record, ("package.json",), f"{manager} script {script}", directory)
            record["unresolved"].append(f"what the package.json script {script!r} runs")
            self.use(record, "node")
        elif sub in ("pack", "publish"):
            record["kind"] = "build"
            self.implicit(state, record, ("package.json",), f"{manager} {sub}", directory)
        elif sub in ("config", "set", "cache", "--version", "-v", "version", "whoami", "ls", "list", "audit"):
            record["kind"] = "environment_setup" if sub in ("config", "set") else "output"

    def p_npm(self, state, record, args):
        self.node_manager(state, record, args, "npm")

    def p_yarn(self, state, record, args):
        self.node_manager(state, record, args, "yarn")

    def p_pnpm(self, state, record, args):
        self.node_manager(state, record, args, "pnpm")

    def p_bun(self, state, record, args):
        self.node_manager(state, record, args, "bun")

    def p_corepack(self, state, record, args):
        record["kind"] = "environment_setup"
        self.implicit(state, record, ("package.json",), "corepack packageManager field")

    def p_node(self, state, record, args):
        operands = self.operands(args, {"-r", "--require", "--max-old-space-size"})
        if operands and operands[0] is not None:
            self.script(state, record, operands[0], operands[1:])
            record["program"] = "node"
        else:
            record["kind"] = "script_execution"
            record["unresolved"].append("node with an inline or dynamic script")

    def p_tsc(self, state, record, args):
        record["kind"] = "build"
        options = self.options(args, {"-p", "--project", "--outDir"})
        project = options.get("-p", []) + options.get("--project", [])
        for p in project:
            self.read_arg(state, record, p, "explicit", "TypeScript project")
        if not project:
            self.implicit(state, record, ("tsconfig.json",), "TypeScript project")

    def js_test(self, state, record, args):
        record["kind"] = "test_execution"
        self.implicit(state, record, ("package.json",), f"{record['program']} configuration")
        record["unresolved"].append(f"{record['program']} configuration file and test data")

    p_jest = p_vitest = p_mocha = js_test

    def p_playwright(self, state, record, args):
        if self.operands(args)[:1] == ["install"]:
            self.install(record, "system", "playwright", packages=["browsers"])
        else:
            self.js_test(state, record, args)

    # ── Rust ──────────────────────────────────────────────────────────────────
    def p_cargo(self, state, record, args):
        options = self.options(args, {"--manifest-path", "--target-dir", "-p", "--package", "--features",
                                      "-F", "--target", "-j", "--profile", "--bin", "--example", "--test",
                                      "-Z", "--config", "--exclude"})
        operands = options["_"]
        sub = next((a for a in operands if a is None or not a.startswith("+")), None)   # cargo +nightly test
        manifest = (options.get("--manifest-path") or [None])[0]
        if manifest is not None:
            self.read_arg(state, record, manifest, "explicit", "cargo manifest")
            where, path = resolve_path(state, manifest)
            directory = os.path.dirname(path) or "." if where == "workspace" else None
        else:
            directory = state.cwd
        if sub in ("build", "b", "check", "c", "test", "t", "nextest", "run", "r", "bench", "clippy",
                   "doc", "d", "fetch", "llvm-cov", "tarpaulin", "miri", "hack", "fmt", "install", "publish",
                   "package", "update", "generate-lockfile", "deny", "audit"):
            record["kind"] = {"test": "test_execution", "t": "test_execution", "nextest": "test_execution",
                              "bench": "test_execution", "llvm-cov": "test_execution",
                              "tarpaulin": "test_execution", "miri": "test_execution",
                              "clippy": "static_analysis", "fmt": "static_analysis", "deny": "static_analysis",
                              "audit": "static_analysis", "fetch": "dependency_installation",
                              "update": "dependency_installation",
                              "generate-lockfile": "dependency_installation"}.get(sub, "build")
            if sub == "install":
                if "--path" in args:
                    target = args[args.index("--path") + 1] if args.index("--path") + 1 < len(args) else None
                    self.read_arg(state, record, target, "explicit", "cargo install --path", directory=True)
                self.install(record, "rust", "cargo", tool=True)
                return
            if manifest is None:
                self.implicit(state, record, CARGO_MANIFEST, f"cargo {sub}", directory)
            else:
                self.implicit(state, record, CARGO_MANIFEST[1:], f"cargo {sub}", directory)
            if sub not in ("fmt", "fetch", "update", "generate-lockfile", "deny", "audit"):
                target = (options.get("--target-dir") or [None])[0]
                if target is not None:
                    self.write_arg(state, record, target, "explicit", "cargo target directory", True)
                elif directory is not None:
                    self.write(record, os.path.normpath(os.path.join(directory, "target")), "implicit",
                               "cargo target directory", True)
            if record["kind"] == "test_execution":
                record["unresolved"].append("data the tests read at run time")
        elif sub is not None and sub.startswith("+"):
            record["kind"] = "build"
        else:
            record["kind"] = "unknown"

    def p_rustup(self, state, record, args):
        record["kind"] = "environment_setup"
        operands = self.operands(args, {"--profile", "-c", "--component", "-t", "--target"})
        if operands[:2] in (["toolchain", "install"], ["component", "add"], ["target", "add"]) or \
                operands[:1] in (["default"], ["install"], ["override"]):
            self.install(record, "rust", "rustup")
        self.implicit(state, record, ("rust-toolchain.toml", "rust-toolchain"), "rustup toolchain file")

    # ── Go ────────────────────────────────────────────────────────────────────
    def p_go(self, state, record, args):
        options = self.options(args, {"-C", "-o", "-tags", "-ldflags", "-run", "-timeout", "-p", "-coverprofile",
                                      "-covermode", "-count", "-modfile", "-mod", "-bench", "-parallel"})
        operands = options["_"]
        sub = operands[0] if operands else None
        directory = self.project_dir(state, options["-C"][0]) if options.get("-C") else state.cwd
        if sub in ("build", "test", "vet", "run", "install", "generate", "mod", "get", "list", "work"):
            record["kind"] = {"test": "test_execution", "vet": "static_analysis", "generate": "file_generation",
                              "mod": "dependency_installation", "get": "dependency_installation"}.get(sub, "build")
            if sub == "install" and any(a and "@" in a for a in operands[1:]):
                self.install(record, "go", "go", tool=True)
                return
            for modfile in options.get("-modfile", []):
                self.read_arg(state, record, modfile, "explicit", "go -modfile")
            self.implicit(state, record, ("go.mod", "go.sum", "go.work"), f"go {sub}", directory)
            if sub == "mod" and operands[1:2] == ["download"]:
                self.install(record, "go", "go")
            for target in options.get("-o", []) + options.get("-coverprofile", []):
                self.write_arg(state, record, target, "explicit", f"go {sub} output")
            if sub == "generate":
                record["unresolved"].append("files go:generate directives write")
            if sub == "test":
                record["unresolved"].append("data the tests read at run time")
        else:
            record["kind"] = "unknown"

    # ── Java ──────────────────────────────────────────────────────────────────
    def p_mvn(self, state, record, args):
        options = self.options(args, {"-f", "--file", "-s", "--settings", "-pl", "--projects", "-P",
                                      "--activate-profiles", "-T", "-gs", "-t", "--toolchains", "-rf"})
        goals = [a for a in options["_"] if a is not None]
        pom = options.get("-f", []) + options.get("--file", [])
        directory = state.cwd
        for f in pom:
            self.read_arg(state, record, f, "explicit", "Maven POM")
            where, path = resolve_path(state, f)
            directory = (path if not path.endswith(".xml") else os.path.dirname(path) or ".") \
                if where == "workspace" else None
        if not pom:
            self.implicit(state, record, ("pom.xml",), "Maven POM", directory)
        self.implicit(state, record, (".mvn/maven.config", ".mvn/jvm.config", ".mvn/extensions.xml"),
                      "Maven project configuration", directory)
        if record["program"] == "mvnw":
            self.implicit(state, record, (".mvn/wrapper/maven-wrapper.properties",), "Maven wrapper", directory)
        for f in options.get("-s", []) + options.get("--settings", []) + options.get("-t", []):
            self.read_arg(state, record, f, "explicit", "Maven settings")
        skip_tests = any(a and re.match(r"-D(?:skipTests|maven\.test\.skip)(?:=true)?$", a) for a in args)
        testing = {"test", "verify", "integration-test", "install", "deploy", "package"}
        if any(g.startswith("dependency:") for g in goals) and not any(g in testing for g in goals):
            self.install(record, "java", "maven")
        elif any(g in ("test", "verify", "integration-test") for g in goals) or \
                (any(g in testing for g in goals) and not skip_tests):
            record["kind"] = "test_execution"
        elif goals:
            record["kind"] = "build"
        if options.get("-pl") or options.get("--projects"):
            record["unresolved"].append("Maven -pl: module paths resolved from the POM")
        if directory is not None and goals and record["kind"] != "dependency_installation":
            self.write(record, os.path.normpath(os.path.join(directory, "target")), "implicit", "Maven build output", True)
        record["installs"].append({"ecosystem": "java", "manager": "maven", "cache": "~/.m2"})

    p_mvnw = p_mvn

    def p_gradle(self, state, record, args):
        options = self.options(args, {"-p", "--project-dir", "-b", "--build-file", "-c", "--settings-file",
                                      "-x", "--exclude-task", "-P", "-D", "--init-script", "-I"})
        tasks = [a for a in options["_"] if a is not None]
        directory = self.project_dir(state, (options.get("-p") or options.get("--project-dir"))[0]) \
            if options.get("-p") or options.get("--project-dir") else state.cwd
        build_files = options.get("-b", []) + options.get("--build-file", [])
        for f in build_files:
            self.read_arg(state, record, f, "explicit", "Gradle build file")
        self.implicit(state, record, GRADLE_FILES if not build_files else GRADLE_FILES[2:], "Gradle build", directory)
        if record["program"] == "gradlew":
            self.implicit(state, record, ("gradle/wrapper/gradle-wrapper.properties",), "Gradle wrapper", directory)
        excluded = set(options.get("-x", []) + options.get("--exclude-task", []))
        names = {t.rsplit(":", 1)[-1] for t in tasks}
        if names & {"test", "check", "build", "connectedCheck", "integrationTest"} and "test" not in excluded:
            record["kind"] = "test_execution"
        elif any(n.startswith(("dependencies", "resolve", "download")) for n in names):
            self.install(record, "java", "gradle")
        else:
            record["kind"] = "build" if tasks else "unknown"
        if directory is not None and tasks:
            self.write(record, os.path.normpath(os.path.join(directory, "build")), "implicit", "Gradle build output", True)

    p_gradlew = p_gradle

    def p_ant(self, state, record, args):
        record["kind"] = "build"
        self.implicit(state, record, ("build.xml",), "Ant build file", upward=False)

    def p_sbt(self, state, record, args):
        record["kind"] = "test_execution" if any(a and "test" in a for a in args) else "build"
        self.implicit(state, record, ("build.sbt", "project/build.properties"), "sbt build")

    # ── C / C++ ───────────────────────────────────────────────────────────────
    def p_cmake(self, state, record, args):
        options = self.options(args, {"-S", "-B", "--build", "--install", "-G", "-D", "-C", "--preset",
                                      "--target", "-t", "--config", "-j", "--parallel", "-T", "-A",
                                      "--toolchain", "--prefix", "--component", "-P", "-E"})
        if options.get("-E") is not None or (args and args[0] == "-E"):
            record["kind"] = "file_operation"
            record["unresolved"].append("cmake -E: platform-independent file command")
            return
        if options.get("--build"):
            record["kind"] = "build"
            for d in options["--build"]:
                self.read_arg(state, record, d, "explicit", "configured build tree", directory=True)
                self.write_arg(state, record, d, "explicit", "build tree", directory=True)
            return
        if options.get("--install"):
            record["kind"] = "build"
            for d in options["--install"]:
                self.read_arg(state, record, d, "explicit", "built tree installed", directory=True)
            for d in options.get("--prefix", []):
                self.write_arg(state, record, d, "explicit", "install prefix", directory=True)
            return
        if options.get("-P"):
            record["kind"] = "script_execution"
            for f in options["-P"]:
                self.read_arg(state, record, f, "explicit", "CMake script")
            return
        record["kind"] = "build"
        source = (options.get("-S") or [None])[0]
        build = (options.get("-B") or [None])[0]
        operands = options["_"]
        if source is None:
            source = operands[0] if operands else ("." if build is not None else None)
        if build is None:
            build = "." if source is not None else None
        if options.get("--preset"):
            self.implicit(state, record, ("CMakePresets.json", "CMakeUserPresets.json"), "CMake presets")
            source = source or "."
        if source is not None:
            where, path = resolve_path(state, source)
            if where == "workspace":
                self.read(record, os.path.normpath(os.path.join(path, "CMakeLists.txt")), "implicit",
                          "CMake source tree")
            else:
                record["unresolved"].append(f"CMake source directory: {path}")
        if build is not None:
            self.write_arg(state, record, build, "explicit" if options.get("-B") else "implicit",
                           "CMake build tree", directory=True)
        for definition in options.get("-D", []):
            name, _, value = (definition or "").partition("=")
            if name.split(":")[0] == "CMAKE_TOOLCHAIN_FILE":
                self.read_arg(state, record, value, "explicit", "CMake toolchain file")
        for f in options.get("--toolchain", []) + options.get("-C", []):
            self.read_arg(state, record, f, "explicit", "CMake toolchain / cache file")

    def p_ctest(self, state, record, args):
        record["kind"] = "test_execution"
        options = self.options(args, {"--test-dir", "-C", "--build-config", "-R", "-E", "-j", "-L",
                                      "--output-junit", "--timeout", "--preset"})
        directory = (options.get("--test-dir") or ["."])[0]
        self.read_arg(state, record, directory, "explicit" if options.get("--test-dir") else "implicit",
                      "CTest build tree", directory=True)
        record["unresolved"].append("data the tests read at run time")

    def p_make(self, state, record, args):
        options = self.options(args, {"-C", "--directory", "-f", "--file", "--makefile", "-j", "--jobs", "-l",
                                      "-I", "-o", "-W"})
        targets = [a for a in options["_"] if a is not None and "=" not in a]
        directory = state.cwd
        for d in options.get("-C", []) + options.get("--directory", []):
            directory = self.project_dir(state, d)
            if directory is None:
                record["unresolved"].append("make -C: dynamic directory")
        files = options.get("-f", []) + options.get("--file", []) + options.get("--makefile", [])
        for f in files:
            self.read_arg(state, record, f, "explicit", "makefile")
        if not files and directory is not None:
            self.implicit(state, record, ("GNUmakefile", "makefile", "Makefile"), "makefile", directory, upward=False)
        record["kind"] = "test_execution" if any(re.search(r"test|check", t) for t in targets) else (
            "dependency_installation" if any(re.search(r"^(?:deps|dependencies|install-deps|bootstrap)$", t)
                                             for t in targets) else "build")
        record["targets"] = targets
        record["unresolved"].append("files the make recipes read and write")

    p_gmake = p_make

    def p_ninja(self, state, record, args):
        options = self.options(args, {"-C", "-f", "-j", "-t"})
        directory = self.project_dir(state, options["-C"][0]) if options.get("-C") else state.cwd
        record["kind"] = "test_execution" if any(a in ("test", "check") for a in options["_"]) else "build"
        self.implicit(state, record, ("build.ninja",), "ninja build file", directory, upward=False)

    def p_meson(self, state, record, args):
        options = self.options(args, {"-C", "--buildtype", "-D", "--prefix", "--native-file", "--cross-file"})
        operands = options["_"]
        sub = operands[0] if operands else None
        if sub in ("compile", "test", "install", "dist"):
            record["kind"] = "test_execution" if sub == "test" else "build"
            for d in options.get("-C", []) or ["."]:
                self.read_arg(state, record, d, "explicit" if options.get("-C") else "implicit",
                              "meson build directory", directory=True)
            return
        record["kind"] = "build"
        rest = operands[1:] if sub in ("setup", "configure") else operands
        self.implicit(state, record, ("meson.build", "meson_options.txt", "meson.options"), "meson project",
                      upward=False)
        if rest:
            self.write_arg(state, record, rest[0], "explicit", "meson build directory", directory=True)
        for f in options.get("--native-file", []) + options.get("--cross-file", []):
            self.read_arg(state, record, f, "explicit", "meson machine file")

    def p_bazel(self, state, record, args):
        operands = self.operands(args, {"--config", "-c", "--compilation_mode", "--jobs", "-j"})
        sub = operands[0] if operands else None
        record["kind"] = {"test": "test_execution", "coverage": "test_execution", "build": "build",
                          "run": "build", "fetch": "dependency_installation", "sync": "dependency_installation"
                          }.get(sub, "unknown")
        self.implicit(state, record, ("MODULE.bazel", "WORKSPACE", "WORKSPACE.bazel", ".bazelrc", ".bazelversion"),
                      "Bazel workspace")
        record["unresolved"].append("BUILD files of the targets")

    p_bazelisk = p_bazel

    def p_conan(self, state, record, args):
        operands = self.operands(args, {"-s", "--settings", "-o", "--options", "-pr", "--profile", "-of",
                                        "--output-folder", "-b", "--build", "-c"})
        if operands[:1] in (["install"], ["create"], ["build"]):
            self.install(record, "system", "conan")
            target = operands[1] if len(operands) > 1 else "."
            where, path = resolve_path(state, target)
            if where == "workspace" and path.endswith((".txt", ".py")):
                self.read(record, path, "explicit", "conanfile")
            elif where == "workspace":
                for name in ("conanfile.txt", "conanfile.py"):
                    self.read(record, os.path.normpath(os.path.join(path, name)), "implicit", "conanfile")

    def p_vcpkg(self, state, record, args):
        operands = self.operands(args, {"--triplet", "--x-install-root", "--overlay-ports"})
        if operands[:1] == ["install"]:
            self.install(record, "system", "vcpkg")
            if len(operands) == 1:
                self.implicit(state, record, ("vcpkg.json", "vcpkg-configuration.json"), "vcpkg manifest")

    def compiler(self, state, record, args):
        record["kind"] = "build"
        options = self.options(args, {"-o", "-I", "-L", "-l", "-D", "-include", "-std", "-x", "-MF"})
        for f in options["_"]:
            if f is not None and re.search(r"\.(?:c|cc|cpp|cxx|c\+\+|s|S|o|a)$", f):
                self.read_arg(state, record, f, "explicit", "compiler input")
        for f in options.get("-o", []):
            self.write_arg(state, record, f, "explicit", "compiler output")

    p_gcc = p_g__ = p_clang = p_clang__ = p_cc = p_c__ = compiler

    # ── other ecosystems ──────────────────────────────────────────────────────
    def p_bundle(self, state, record, args):
        operands = self.operands(args, {"--gemfile", "--path", "-j", "--jobs"})
        if operands[:1] in (["install"], []):
            self.install(record, "ruby", "bundler")
            self.implicit(state, record, ("Gemfile", "Gemfile.lock"), "bundle install")

    def p_gem(self, state, record, args):
        if self.operands(args)[:1] == ["install"]:
            self.install(record, "ruby", "gem")

    def p_dotnet(self, state, record, args):
        operands = self.operands(args, {"-c", "--configuration", "-f", "--framework", "-o", "--output",
                                        "-r", "--runtime", "--logger", "-p", "--project"})
        sub = operands[0] if operands else None
        record["kind"] = {"test": "test_execution", "restore": "dependency_installation", "build": "build",
                          "publish": "build", "pack": "build", "tool": "dependency_installation"}.get(sub, "unknown")
        self.implicit(state, record, ("global.json", "NuGet.config", "Directory.Build.props"), f"dotnet {sub}")
        for project in operands[1:2]:
            self.read_arg(state, record, project, "explicit", "project or solution")
        if sub == "restore":
            record["installs"].append({"ecosystem": "dotnet", "manager": "dotnet"})


def _placeholders(script, known=None):
    """`${{ }}` expressions replaced by placeholders (dynamic), except the ones whose
    value is known statically (`github.workspace`, `github.action_path`)."""
    expressions = []

    def keep(match):
        expression = match.group(1).strip()
        if expression in (known or {}):
            return known[expression]
        expressions.append(expression)
        return f"__GHA_EXPR_{len(expressions) - 1}__"

    return GHA_EXPRESSION.sub(keep, script), expressions


# ── bash front end (tree-sitter-bash) ─────────────────────────────────────────
class _Bash:
    """Walks a tree-sitter-bash tree, emitting commands into an Analysis in execution order."""

    def __init__(self, analysis, source, via=(), depth=0):
        self.a, self.src, self.via, self.depth = analysis, source, list(via), depth

    def text(self, node):
        return self.src[node.start_byte:node.end_byte].decode("utf-8", errors="replace")

    def value(self, node, state):
        """The static string a word denotes, or None if it depends on the run."""
        kind = node.type
        if kind in ("word", "number"):
            text = self.text(node)
            text = re.sub(r"\\(.)", r"\1", text)
            if text.startswith("~"):
                text = HOME + text[1:]
            return text
        if kind == "raw_string":
            return self.text(node)[1:-1]
        if kind == "ansi_c_string":
            return self.text(node)[2:-1]
        if kind in ("string", "concatenation", "translated_string"):
            parts = []
            for child in node.children:
                if child.type in ('"', "$"):
                    continue
                if child.type == "string_content":
                    parts.append(self.text(child))
                    continue
                part = self.value(child, state)
                if part is None:
                    return None
                parts.append(part)
            return "".join(parts)
        if kind in ("simple_expansion", "expansion"):
            names = [c for c in node.children if c.type in ("variable_name", "special_variable_name")]
            if len(names) != 1 or (kind == "expansion" and len(node.children) != 3):
                for child in node.children:          # ${X:-default}, ${X%/*}: dynamic
                    if child.type == "command_substitution":
                        self.walk(child, state.copy())
                return None
            name = self.text(names[0])
            if name == "GITHUB_WORKSPACE":
                return WORKSPACE
            if name in GITHUB_FILES:
                return f"${name}"
            if name == "HOME":
                return HOME
            return state.vars.get(name)
        if kind in ("command_substitution", "process_substitution", "arithmetic_expansion"):
            self.walk(node, state.copy())            # its commands still run
            return None
        if kind == "string_content":
            return self.text(node)
        return None

    def words(self, node, state):
        name = node.child_by_field_name("name")
        words = [self.value(name.named_children[0], state) if name and name.named_children else None]
        for argument in node.children_by_field_name("argument"):
            words.append(self.value(argument, state))
        return words

    def run(self, code, state):
        tree = _BASH.parse(code.encode("utf-8"))
        if tree.root_node.has_error:
            self.a.parse_errors.append(_first_error(tree.root_node, code))
        self.src = code.encode("utf-8")
        self.walk(tree.root_node, state)

    def walk(self, node, state, redirects=()):
        kind = node.type
        if kind in ("program", "compound_statement", "do_group", "ERROR", "command_substitution",
                    "process_substitution"):
            for child in node.named_children:
                self.walk(child, state)
        elif kind == "list":
            guarded = False
            for child in node.children:
                if child.type == "||":
                    guarded = True
                elif child.is_named:
                    if guarded:
                        branch = state.copy(guarded=True)
                        self.walk(child, branch)
                        state.join(branch)
                    else:
                        self.walk(child, state)
        elif kind == "pipeline":
            for child in node.named_children:          # each element runs in a subshell
                self.walk(child, state.copy())
        elif kind == "subshell":
            inner = state.copy()
            for child in node.named_children:
                self.walk(child, inner)
        elif kind == "redirected_statement":
            body = node.child_by_field_name("body")
            targets = []
            for redirect in node.children_by_field_name("redirect"):
                targets += self.redirects(redirect, state)
            if body is None:
                return
            before = len(self.a.commands)
            self.walk(body, state, targets if body.type == "command" else ())
            if body.type != "command":                 # a compound body: its commands share the redirection
                for record in self.a.commands[before:]:
                    for operator, target in targets:
                        self.a.redirect(state, record, operator, target)
        elif kind == "command":
            self.command(node, state, redirects)
        elif kind == "variable_assignments":
            for child in node.named_children:
                self.walk(child, state)
        elif kind == "variable_assignment":
            name = node.child_by_field_name("name")
            value = node.child_by_field_name("value")
            state.vars[self.text(name)] = self.value(value, state) if value is not None else ""
        elif kind == "declaration_command":
            record = self.a.command(state, [self.text(node.children[0])], self.text(node),
                                    node.start_point[0] + 1, via=self.via)
            record["kind"] = "environment_setup"
            record["assigns"] = []
            for child in node.named_children:
                if child.type == "variable_assignment":
                    self.walk(child, state)
                    record["assigns"].append(self.text(child.child_by_field_name("name")))
        elif kind == "unset_command":
            for child in node.named_children:
                state.vars.pop(self.text(child), None)
        elif kind in ("if_statement", "elif_clause", "else_clause", "while_statement", "for_statement",
                      "c_style_for_statement", "case_statement", "case_item"):
            self.compound(node, state)
        elif kind == "function_definition":
            name = node.child_by_field_name("name")
            state.functions[self.text(name)] = node.child_by_field_name("body")
        elif kind == "negated_command":
            for child in node.named_children:
                self.walk(child, state)
        elif kind == "test_command":
            self.a.command(state, ["["], self.text(node), node.start_point[0] + 1, via=self.via)
            for child in node.named_children:          # substitutions inside a test still run
                self.substitutions(child, state)
        elif kind in ("comment", "heredoc_body"):
            return
        else:
            self.substitutions(node, state)

    def substitutions(self, node, state):
        if node.type in ("command_substitution", "process_substitution"):
            self.walk(node, state.copy())
            return
        for child in node.named_children:
            self.substitutions(child, state)

    def compound(self, node, state):
        """if / while / for / case: the condition runs; a body may not, so it runs on a
        guarded copy whose changes (cwd, variables) become unknown afterwards."""
        in_body = node.type in ("else_clause", "case_item")
        branch = None

        def close():
            nonlocal branch
            if branch is not None:
                state.join(branch)
                branch = None

        for i, child in enumerate(node.children):
            field = node.field_name_for_child(i)
            if child.type in ("then", "do", "else"):
                in_body = True
                continue
            if not child.is_named or child.type == "comment":
                continue
            if field in ("variable", "value") and node.type in ("for_statement", "case_item", "case_statement"):
                self.substitutions(child, state)
                if node.type == "for_statement" and field == "variable":
                    state.vars[self.text(child)] = None
            elif field == "condition" and not in_body:
                self.walk(child, state)
            elif child.type in ("elif_clause", "else_clause", "case_item"):
                close()
                clause = state.copy(guarded=True)
                self.walk(child, clause)
                state.join(clause)
            elif in_body or field == "body":
                if branch is None:
                    branch = state.copy(guarded=True)
                self.walk(child, branch)
            else:
                self.walk(child, state)
        close()

    def redirects(self, redirect, state):
        out = []
        if redirect.type == "file_redirect":
            operator = next((self.text(c) for c in redirect.children if not c.is_named), ">")
            destination = redirect.child_by_field_name("destination")
            if operator in (">&", "<&") and destination is not None and destination.type == "number":
                return out
            if destination is not None:
                out.append((operator, self.value(destination, state)))
        elif redirect.type == "heredoc_redirect":
            for child in redirect.children_by_field_name("redirect"):
                out += self.redirects(child, state)
        return out

    def command(self, node, state, redirects):
        assignments = {}
        for child in node.children:
            if child.type == "variable_assignment":
                value = child.child_by_field_name("value")
                assignments[self.text(child.child_by_field_name("name"))] = \
                    self.value(value, state) if value is not None else ""
            elif child.type in ("file_redirect", "heredoc_redirect", "herestring_redirect"):
                redirects = list(redirects) + self.redirects(child, state)
        for child in node.children_by_field_name("argument"):
            self.substitutions(child, state)
        words = self.words(node, state)
        line = node.start_point[0] + 1
        if words[0] is not None and words[0] in state.functions and self.depth < 3:
            record = self.a.command(state, words, self.text(node), line, assignments, redirects, self.via)
            record["kind"], record["program"] = "script_execution", words[0]
            record["function"] = True
            inner = _Bash(self.a, self.src, self.via + [f"function {words[0]}"], self.depth + 1)
            inner.walk(state.functions[words[0]], state)
            return
        scoped = state.copy() if assignments else state
        for name, value in assignments.items():       # VAR=x cmd: visible to cmd only
            scoped.vars[name] = value
        record = self.a.command(scoped, words, self.text(node), line, assignments, redirects, self.via)
        if scoped is not state and record is not None and record["kind"] == "directory_change":
            state.cwd = scoped.cwd


def _first_error(root, code):
    stack = [root]
    while stack:
        node = stack.pop()
        if node.type == "ERROR" or node.is_missing:
            line = node.start_point[0]
            return f"line {line + 1}: {code.splitlines()[line].strip()[:80] if line < len(code.splitlines()) else ''}"
        stack.extend(reversed(node.children))
    return "syntax error"


def _bash(self, code, state, via=(), depth=0):
    if _BASH is None:
        self.note("tree-sitter-bash is not installed: script not analysed")
        return
    if depth > 3:
        self.note("nested shell deeper than 3 levels not analysed")
        return
    _Bash(self, b"", via, depth).run(code, state)


Analysis.bash = _bash


# ── PowerShell and cmd front ends (lexical) ───────────────────────────────────
def _split(text, separators, quotes, escape):
    """Split on unquoted separators; returns the parts (separators dropped)."""
    parts, current, quote, i = [], [], None, 0
    while i < len(text):
        ch = text[i]
        if quote:
            current.append(ch)
            if ch == escape and i + 1 < len(text):
                current.append(text[i + 1])
                i += 2
                continue
            if ch == quote:
                quote = None
        elif ch in quotes:
            quote = ch
            current.append(ch)
        elif ch == escape and i + 1 < len(text):
            current.append(text[i:i + 2])
            i += 2
            continue
        else:
            separator = next((s for s in separators if text.startswith(s, i)), None)
            if separator is not None:
                parts.append(("".join(current), separator))
                current = []
                i += len(separator)
                continue
            current.append(ch)
        i += 1
    parts.append(("".join(current), None))
    return parts


def _powershell(self, script, state):
    script = re.sub(r"`\r?\n", " ", script)            # backtick continuation
    script = re.sub(r"<#.*?#>", "", script, flags=re.DOTALL)
    depth = 0
    for line_number, line in enumerate(script.splitlines(), 1):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        for statement, separator in _split(stripped, (";", "&&", "||"), "'\"", "`"):
            statement = statement.strip()
            keyword = re.match(r"^(}\s*)?(if|elseif|else|foreach|for|while|do|try|catch|finally|switch|function)\b",
                               statement, re.IGNORECASE)
            if keyword or statement.startswith(("{", "}")):
                depth += statement.count("{") - statement.count("}")
                statement = statement.split("{", 1)[1] if "{" in statement else ""
                statement = statement.rsplit("}", 1)[0] if statement.count("}") > statement.count("{") else statement
                statement = statement.strip()
                if not statement:
                    continue
            elif statement.endswith("}") and depth > 0:
                depth -= 1
                statement = statement[:-1].strip()
            branch = state.copy(guarded=True) if depth > 0 or keyword else state
            for element, _ in _split(statement, ("|",), "'\"", "`"):
                _powershell_statement(self, element.strip(), branch if depth or keyword else state, line_number)
            if branch is not state:
                state.join(branch)


def _ps_value(token, state):
    if token.startswith("'") and token.endswith("'") and len(token) >= 2:
        return token[1:-1]
    if token.startswith('"') and token.endswith('"') and len(token) >= 2:
        token = token[1:-1]
    def variable(match):
        name = match.group(1) or match.group(2)
        if name.lower() in ("env:github_workspace", "github_workspace"):
            return WORKSPACE
        if name.lower() in ("env:home", "home", "env:userprofile"):
            return HOME
        if name.lower().startswith("env:") and name[4:] in GITHUB_FILES:
            return f"$env:{name[4:]}"
        value = state.vars.get(name.lower())
        return value if value is not None else "\x00"
    token = re.sub(r"\$\{([^}]+)\}|\$((?:env:)?[A-Za-z_][\w]*)", variable, token)
    if "\x00" in token or "$(" in token:
        return None
    return token


def _powershell_statement(self, statement, state, line):
    if not statement:
        return
    assignment = re.match(r"^\$(env:)?([\w]+)\s*=\s*(.*)$", statement, re.IGNORECASE)
    if assignment:
        tokens = [t for t, _ in _split(assignment.group(3).strip(), (" ",), "'\"", "`") if t]
        value = _ps_value(tokens[0], state) if len(tokens) == 1 else None
        state.vars[((assignment.group(1) or "") + assignment.group(2)).lower()] = value
        if assignment.group(1):
            record = self.command(state, ["export"], statement, line)
            record["program"] = "$env:" + assignment.group(2)
        return
    statement = re.sub(r"^&\s*", "", statement)
    redirects, tokens = [], []
    raw = [t for t, _ in _split(statement, (" ", "\t"), "'\"", "`") if t]
    i = 0
    while i < len(raw):
        match = re.match(r"^(\d|\*)?(>>|>)(.*)$", raw[i])
        if match and not raw[i].startswith(("'", '"')):
            target = match.group(3) or (raw[i + 1] if i + 1 < len(raw) else None)
            if not match.group(3):
                i += 1
            if not (match.group(1) and target and target.startswith("&")):
                redirects.append((match.group(2), _ps_value(target, state) if target else None))
        else:
            tokens.append(raw[i])
        i += 1
    if not tokens:
        return
    words = [_ps_value(t, state) for t in tokens]
    aliases = {"set-location": "Set-Location", "sl": "Set-Location", "push-location": "Push-Location",
               "pop-location": "Pop-Location", "copy-item": "Copy-Item", "move-item": "Move-Item",
               "remove-item": "Remove-Item", "new-item": "New-Item", "out-file": "Out-File",
               "set-content": "Set-Content", "add-content": "Add-Content", "get-content": "Get-Content",
               "expand-archive": "Expand-Archive", "invoke-webrequest": "Invoke-WebRequest",
               "write-host": "Write-Host", "write-output": "Write-Output", "echo": "Write-Output",
               "ni": "New-Item", "gc": "Get-Content", "ri": "Remove-Item"}
    if words[0] is not None and words[0].lower() in aliases:
        words[0] = aliases[words[0].lower()]
    if words[0] is not None and words[0].lower() == "cd":
        words[0] = "cd"
    self.command(state, words, statement, line, redirects=redirects)


def _cmd(self, script, state):
    script = re.sub(r"\^\r?\n", "", script)
    for line_number, line in enumerate(script.splitlines(), 1):
        stripped = line.strip().lstrip("@")
        if not stripped or re.match(r"^(?:rem\b|::)", stripped, re.IGNORECASE):
            continue
        guarded = False
        for statement, separator in _split(stripped, ("&&", "||", "&"), '"', "^"):
            statement = statement.strip().strip("()").strip()
            condition = re.match(r"^if\s+(?:not\s+)?(?:exist\s+\S+|errorlevel\s+\d+|defined\s+\S+|\S+==\S+)\s+(.*)$",
                                 statement, re.IGNORECASE)
            loop = re.match(r"^for\s+.*?\bdo\s+(.*)$", statement, re.IGNORECASE)
            if condition or loop:
                statement = (condition or loop).group(1).strip().strip("()")
                guarded = True
            target = state.copy(guarded=True) if guarded else state
            for element, _ in _split(statement, ("|",), '"', "^"):
                _cmd_statement(self, element.strip(), target, line_number)
            if target is not state:
                state.join(target)
            if separator == "||":
                guarded = True


def _cmd_statement(self, statement, state, line):
    if not statement:
        return
    assignment = re.match(r'^set\s+(?:/a\s+)?"?([\w]+)=(.*?)"?$', statement, re.IGNORECASE)
    if assignment:
        value = assignment.group(2)
        state.vars[assignment.group(1).upper()] = None if "%" in value or "!" in value else value
        record = self.command(state, ["export"], statement, line)
        record["program"] = "set"
        return
    raw = [t for t, _ in _split(statement, (" ", "\t"), '"', "^") if t]
    redirects, tokens, i = [], [], 0
    while i < len(raw):
        match = re.match(r"^(\d)?(>>|>|<)(.*)$", raw[i])
        if match and not raw[i].startswith('"'):
            target = match.group(3) or (raw[i + 1] if i + 1 < len(raw) else None)
            if not match.group(3):
                i += 1
            if not (target or "").startswith("&"):
                redirects.append((match.group(2), _cmd_value(target, state) if target else None))
        else:
            tokens.append(raw[i])
        i += 1
    if not tokens:
        return
    words = [_cmd_value(t, state) for t in tokens]
    if words[0] is not None:
        words[0] = {"call": None}.get(words[0].lower(), words[0])
        if words[0] is None:                       # call script.bat args
            words = words[1:]
            if words and words[0] is not None and not words[0].startswith(("./", ".\\")):
                words[0] = "./" + words[0]
    if words and words[0] is not None and words[0].lower() in ("cd", "chdir", "pushd", "popd", "copy", "xcopy",
                                                                "move", "del", "type", "mkdir", "md", "rmdir"):
        words[0] = words[0].lower()
    if words and words[0] is not None and words[0].lower() in ("echo", "echo.", "title", "setlocal", "endlocal",
                                                                "exit", "goto", "pause", "ver"):
        record = self.command(state, words[:1], statement, line, redirects=redirects)
        if record and record["kind"] == "unknown":
            record["kind"] = "output"
        return
    self.command(state, words, statement, line, redirects=redirects)


def _cmd_value(token, state):
    token = token.strip('"')
    def variable(match):
        name = match.group(1).upper()
        if name == "GITHUB_WORKSPACE":
            return WORKSPACE
        if name in GITHUB_FILES:
            return f"${name}"
        if name in ("USERPROFILE", "HOME"):
            return HOME
        value = state.vars.get(name)
        return value if value is not None else "\x00"
    token = re.sub(r"%([\w]+)%", variable, token)
    return None if "\x00" in token or "!" in token else token


Analysis.powershell = _powershell
Analysis.cmd = _cmd


# ── entry point ───────────────────────────────────────────────────────────────
def shell_family(shell, runner_os=None):
    """("bash" | "pwsh" | "cmd" | other name, the shell as declared) for a step's `shell:`."""
    if not shell:
        return ("pwsh" if runner_os == "Windows" else "bash"), None
    words = re.findall(r"[\w.+-]+", str(shell).replace("{0}", ""))
    for word in words:
        name = word.lower()
        if name in SHELLS:
            return "bash", shell
        if name in ("pwsh", "powershell"):
            return "pwsh", shell
        if name == "cmd":
            return "cmd", shell
    return (words[0].lower() if words else str(shell)), shell


def analyze_script(script, shell=None, runner_os=None, cwd=".", env=None, action_path=None):
    """The Shell Command IR of one `run:` script.

    `cwd` is the workspace-relative working directory (None when it is an
    expression); `env` the literal environment values the step sees;
    `action_path` the workspace-relative directory of the composite action the
    script belongs to (GITHUB_ACTION_PATH).
    """
    family, declared = shell_family(shell, runner_os)
    known = {"github.workspace": WORKSPACE}
    if action_path is not None:
        known["github.action_path"] = f"{WORKSPACE}/{action_path}"
    code, expressions = _placeholders(script, known)
    analysis = Analysis(family, expressions)
    variables = {k: (None if v is None or PLACEHOLDER.search(str(v)) else str(v))
                 for k, v in (env or {}).items()}
    if action_path is not None:
        variables["GITHUB_ACTION_PATH"] = known["github.action_path"]
    if family == "pwsh":
        variables = {**{k.lower(): v for k, v in variables.items()},
                     **{"env:" + k.lower(): v for k, v in variables.items()}}
    elif family == "cmd":
        variables = {k.upper(): v for k, v in variables.items()}
    state = State(cwd, variables)
    parsed_by = {"bash": "tree-sitter-bash" if _BASH is not None else "unavailable",
                 "pwsh": "powershell-lexical", "cmd": "cmd-lexical"}.get(family, "unsupported")
    if family == "bash":
        analysis.bash(code, state)
    elif family == "pwsh":
        analysis.powershell(code, state)
    elif family == "cmd":
        analysis.cmd(code, state)
    else:
        analysis.note(f"shell {declared or family!r} is not analysed: the script is opaque")
    if cwd is None:
        analysis.note("the step's working-directory is an expression")
    return {"shell": family, "declared_shell": declared, "parsed_by": parsed_by,
            "parse_errors": analysis.parse_errors, "commands": analysis.commands,
            "unresolved": analysis.unresolved, "expressions": expressions}
