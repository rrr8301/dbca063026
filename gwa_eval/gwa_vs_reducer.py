"""Compare GWA with the original LLM YAML Reducer on the evaluation set.

The reducer runs exactly as in llm4build-pipeline.py: the same prompt
(prompts.yaml_reducer_prompt), the same model call (call_claude /
call_openai, temperature 0) and the same output extraction, given the same
inputs -- workflow YAML, API job name, matrix (mat_k) and the steps the
original run completed. GWA is the frozen baseline in frozen/gwa_v1.

The GitHub API no longer lists these jobs' steps (step data goes when a run's
logs expire), so the completed steps are rebuilt from the saved original CI
log: its `Run ...` headers are aligned in order to the target job's steps, and
the executed ones are named as the API names steps. Post-steps are not
recoverable and are omitted. The same alignment is the ground truth.

Each reduced YAML is mapped back onto the frozen GWA graph of the same
workflow: jobs by key, then name; steps by an order-preserving alignment on
structural identity (action, id) and command similarity against the raw and
the matrix-rendered command. Reduced steps are UNCHANGED, MODIFIED, ADDED or
AMBIGUOUS; original steps left unaligned are REMOVED.

Metrics, per method:
  graph-relative (against GWA's own slice -- GWA meets these by construction)
    required-step recall, required-job recall, mandatory dependency recall
  ground truth (independent of GWA: which steps the original run executed,
  from its log; cases whose alignment is uncertain are left out)
    executed-step recall, skipped-step retention
  matrix assignment accuracy, step modification rate, step invention,
  retained-step ratio, analysis cost (tokens, USD, seconds)

Only the dataset cases run: synthetic fixtures have no CI run.

    python gwa_eval/gwa_vs_reducer.py --estimate          # prompt sizes and cost, no calls
    python gwa_eval/gwa_vs_reducer.py [--models ...] [--runs N] [--only <case-id> ...]
"""
import argparse
import csv
import difflib
import importlib.util
import json
import os
import random
import re
import statistics
import sys
import time
from collections import Counter

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
FROZEN = os.path.join(HERE, "frozen", "gwa_v1")
sys.path[:0] = [FROZEN, ROOT]
os.chdir(ROOT)

from gwa import (EXPRESSION, GraphWorkflowAnalyzer, _action_name, _action_ref, _canonical_json,  # noqa: E402
                 load_workflow_yaml)
from prompts import yaml_reducer_prompt  # noqa: E402

GWA_MODULES = ("gwa_conditions", "gwa", "gwa_validation")


def load_version(directory):
    """gwa and gwa_validation from `directory`, kept apart from other loaded versions."""
    saved = {n: sys.modules.pop(n) for n in GWA_MODULES if n in sys.modules}
    sys.path.insert(0, directory)
    try:
        modules = {"gwa": importlib.import_module("gwa"),
                   "gwa_validation": importlib.import_module("gwa_validation")}
        if "gwa_conditions" in sys.modules:
            modules["gwa_conditions"] = sys.modules["gwa_conditions"]
    finally:
        sys.path.remove(directory)
        for name in GWA_MODULES:
            sys.modules.pop(name, None)
        sys.modules.update(saved)
    return modules


def run_version(modules, case, **options):
    """(analyzer, spec, seconds) of one GWA version; its own modules are active while it runs,
    since analyze() imports gwa_validation when called."""
    saved = {n: sys.modules.get(n) for n in modules}
    sys.modules.update(modules)
    try:
        path = os.path.join(HERE, case["checkout"])
        started = time.time()
        analyzer = modules["gwa"].GraphWorkflowAnalyzer(
            path, os.path.join(path, case["workflow"]),
            {"id": case["job_id"], "name": case["job_name"], "labels": case.get("labels") or [],
             "run": case.get("run")}, case["matrix"], **options)
        spec = analyzer.analyze()
        return analyzer, spec, time.time() - started
    finally:
        for name, module in saved.items():
            if module is None:
                sys.modules.pop(name, None)
            else:
                sys.modules[name] = module


GWA_V1 = load_version(FROZEN)        # conservative: every step of the target
GWA_V2 = load_version(ROOT)          # + Static Condition Resolution

OUT = os.path.join(HERE, "comparison")
MODELS = {"claude-haiku-4-5-20251001": "claude-haiku-4-5-20251001", "gpt4o": "gpt-4o"}
YAML_BLOCK = re.compile(r"```(yamlfile|yaml)(.*?)```", re.DOTALL | re.IGNORECASE)   # the pipeline's
MATCH_THRESHOLD = 0.5
SETUP_ACTIONS = ("actions/checkout", "actions/setup-", "actions/cache")
SETUP_COMMAND = re.compile(r"\b(?:pip3?|uv|npm|yarn|pnpm|apt(?:-get)?|brew|cargo|go|conda)\s+"
                           r"(?:install|ci|add|get|sync|i)\b")
REQUIRED_ROLES = ("data_predecessor", "artifact_producer", "call_site")
# USD per million input / output tokens at list price. The pipeline's own table
# (MODEL_PRICING, used for its reported cost) has Haiku 4.5 at the older 0.80 / 4.00.
LIST_PRICE = {"claude-haiku-4-5-20251001": (1.00, 5.00), "gpt4o": (2.50, 10.00)}


# ── running the reducer ───────────────────────────────────────────────────────
def load_pipeline():
    spec = importlib.util.spec_from_file_location("llm4build_pipeline", os.path.join(ROOT, "llm4build-pipeline.py"))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def job_conclusions(cases):
    """Each case's job conclusion from the GitHub API (cached).

    The API no longer lists these jobs' steps -- GitHub drops step data when a
    run's logs expire -- so steps come from the saved original logs instead.
    """
    path = os.path.join(OUT, "job_conclusions.json")
    cached = json.load(open(path)) if os.path.exists(path) else {}
    missing = [c for c in cases if c["id"] not in cached]
    if missing:
        from utils.common.credentials import GITHUB_TOKENS
        from utils.common.github_wrapper import GitHubWrapper
        github = GitHubWrapper(GITHUB_TOKENS)
        for case in missing:
            _, job = github.get(f"https://api.github.com/repos/{case['repo']}/actions/jobs/{case['job_id']}")
            cached[case["id"]] = (job or {}).get("conclusion")
        os.makedirs(OUT, exist_ok=True)
        with open(path, "w") as f:
            json.dump(cached, f, indent=1)
    return cached


LOG_HEADER = re.compile(r"##\[group\]Run (.*)$")


def log_headers(case):
    """The `Run ...` step headers of the job's original CI log, in order; None without a log."""
    name = case["repo"].split("/")[1]
    candidates = [os.path.join(ROOT, "original_logs", f"{name}-{case['job_id']}.log")]
    candidates += sorted(__import__("glob").glob(os.path.join(
        ROOT, "output_data", "llm4build", "*", "*", "*", f"{name}_{case['job_id']}", "out",
        f"{name}-{case['job_id']}.log")))
    path = next((p for p in candidates if os.path.exists(p) and os.path.getsize(p) > 0), None)
    if path is None:
        return None
    with open(path, encoding="utf-8", errors="replace") as f:
        return [m.group(1).strip() for line in f for m in [LOG_HEADER.search(line)] if m]


def header_score(attrs, header):
    """How well a log header `Run <...>` identifies this step: 3 exact, 2 literal prefix, 1 fuzzy, 0 not."""
    if attrs["uses"]:
        if header.lower() == attrs["uses"].lower():
            return 3
        return 2 if header.lower().startswith(_action_name(attrs["uses"]).lower()) else 0
    first = next((line.strip() for line in (attrs["command"] or "").splitlines() if line.strip()), "")
    if not first:
        return 0
    if header == first:
        return 3
    expression = EXPRESSION.search(first)
    if expression:          # evaluated at run time: compare the literal text before it
        literal = first[:expression.start()].strip()
        if literal and header.startswith(literal):
            return 2
    if header.startswith(first[:80]):
        return 2
    return 1 if ratio(normalize(first), normalize(header)) >= 0.8 else 0


def observed_steps(analyzer, headers, conclusion):
    """Target-job steps the original run executed, from its log.

    Returns ({step node: "executed" | "not_executed"}, note); the map is None
    when the alignment is uncertain -- an unmatched step without an `if:`
    before the last matched one, or anywhere in a successful job.
    """
    if headers is None:
        return None, "no original log"
    graph = analyzer.graph
    target = spec_target_node(analyzer)
    steps = sorted((n for n, a in graph.nodes(data=True) if a.get("type") == "step" and a["job"] == target),
                   key=lambda n: graph.nodes[n]["index"])
    # order-preserving alignment of steps to headers, maximising match quality; headers
    # may go unmatched (a composite action's inner steps have headers of their own)
    n, m = len(steps), len(headers)
    scores = [[header_score(graph.nodes[s], h) for h in headers] for s in steps]
    best = [[0] * (m + 1) for _ in range(n + 1)]
    for i in range(n - 1, -1, -1):
        for j in range(m - 1, -1, -1):
            take = scores[i][j] + best[i + 1][j + 1] if scores[i][j] else -1
            best[i][j] = max(take, best[i + 1][j], best[i][j + 1])
    observed = {s: "not_executed" for s in steps}
    matched_header = {}
    i = j = 0
    while i < n and j < m:
        if scores[i][j] and best[i][j] == scores[i][j] + best[i + 1][j + 1]:
            observed[steps[i]] = "executed"
            matched_header[steps[i]] = j
            i, j = i + 1, j + 1
        elif best[i][j] == best[i + 1][j]:
            i += 1
        else:
            j += 1
    # a header that identifies an executed step and an unexecuted one equally well is ambiguous
    for step, j in matched_header.items():
        rivals = [s for k, s in enumerate(steps) if observed[s] == "not_executed"
                  and scores[k][j] >= scores[steps.index(step)][j]]
        if rivals:
            return None, f"uncertain: header {headers[j][:60]!r} fits steps {graph.nodes[step]['index']} " \
                         f"and {graph.nodes[rivals[0]]['index']} equally"
    executed = [graph.nodes[n]["index"] for n, s in observed.items() if s == "executed"]
    last = max(executed) if executed else -1
    suspicious = [n for n, s in observed.items() if s == "not_executed" and graph.nodes[n]["condition"] is None
                  and (graph.nodes[n]["index"] < last or conclusion == "success")]
    if suspicious:
        return None, f"uncertain: {len(suspicious)} unconditional step(s) not found in the log"
    return observed, f"matched ({len(executed)}/{len(steps)} steps executed)"


def completed_steps(analyzer, observed):
    """The step list the pipeline would have passed, rebuilt as the API names steps.

    The API names a step by its `name:`, else `Run <action or first command
    line>`, and lists `Set up job` / `Complete job` around them; post-steps
    cannot be recovered from the log and are left out.
    """
    if observed is None:
        return []
    graph = analyzer.graph
    names = []
    for node in sorted(observed, key=lambda n: graph.nodes[n]["index"]):
        if observed[node] != "executed":
            continue
        attrs = graph.nodes[node]
        first = next((line.strip() for line in (attrs["command"] or "").splitlines() if line.strip()), "")
        names.append(attrs["display_name"] or f"Run {attrs['uses'] or first}")
    return [{"name": "Set up job"}] + [{"name": n} for n in names] + [{"name": "Complete job"}]


def reducer_prompt(case, completed):
    with open(os.path.join(HERE, case["checkout"], case["workflow"]), encoding="utf-8", errors="replace") as f:
        yaml_content = f.read()
    return yaml_reducer_prompt(yaml_content, case["job_name"], case["matrix"], completed)


def run_reducer(pipeline, model, prompt):
    model_id = MODELS[model]
    started = time.time()
    if model_id.startswith("gpt"):
        out = pipeline.call_openai(prompt, model=model_id)
    else:
        out = pipeline.call_claude(prompt, model=model_id)
    seconds = time.time() - started
    match = YAML_BLOCK.search(out["content"] or "")
    return {"model": model_id, "content": out["content"], "reduced_yaml": match.group(2).strip() if match else None,
            "input_tokens": out.get("input_tokens", 0), "output_tokens": out.get("output_tokens", 0),
            "cost_usd": out.get("cost", 0.0), "seconds": round(seconds, 2)}


# ── mapping a reduced YAML onto the GWA graph ─────────────────────────────────
def normalize(text):
    """A command with line continuations joined, full-line comments dropped and whitespace collapsed."""
    lines = [line for line in str(text).replace("\\\n", " ").splitlines() if not line.strip().startswith("#")]
    return " ".join(" ".join(lines).split())


def command_diff(before, after, limit=8):
    lines = [d for d in difflib.unified_diff(
        [l for l in (before or "").splitlines() if l.strip() and not l.strip().startswith("#")],
        [l for l in (after or "").splitlines() if l.strip() and not l.strip().startswith("#")],
        lineterm="", n=0) if d[:1] in "+-" and d[:3] not in ("+++", "---")]
    return lines[:limit] + ([f"... {len(lines) - limit} more"] if len(lines) > limit else [])


def _as_text(value):
    """Scalars as GitHub interpolates them: `25` and `'25'` are the same input."""
    if isinstance(value, dict):
        return {str(k): _as_text(v) for k, v in value.items()}
    if isinstance(value, list):
        return [_as_text(v) for v in value]
    if isinstance(value, bool):
        return "true" if value else "false"
    return "" if value is None else str(value)


def canon(value):
    return _canonical_json(_as_text(value)) if value not in (None, {}, []) else ""


def env_reference(name):
    """`${{ env.X }}`, `${X}` or `$X` for one variable."""
    n = re.escape(name)
    return re.compile(r"\$\{\{\s*env\." + n + r"\s*\}\}|\$\{" + n + r"\}|\$" + n + r"\b")


def substitute_env(value, env):
    """`${{ env.X }}`, `${X}` and `$X` replaced by literal job/workflow env values."""
    if isinstance(value, str):
        for name, literal in env.items():
            value = env_reference(name).sub(lambda _: literal, value)
        return value
    if isinstance(value, dict):
        return {k: substitute_env(v, env) for k, v in value.items()}
    if isinstance(value, list):
        return [substitute_env(v, env) for v in value]
    return value


def ratio(a, b):
    if a == b:
        return 1.0
    matcher = difflib.SequenceMatcher(None, a, b, autojunk=False)
    return matcher.ratio() if matcher.real_quick_ratio() > 0.3 else 0.0


def original_variants(attrs, job_env=None):
    """The ways a reduced step may render an original one without changing it:
    as written, with matrix values substituted, and with literal env values substituted too."""
    raw = attrs["raw_config"]
    rendered = {"name": attrs.get("display_name"), "id": attrs.get("step_id"), "uses": attrs.get("uses"),
                "run": attrs.get("command"), "with": attrs.get("with_"), "env": attrs.get("env"),
                "if": attrs.get("condition"), "shell": attrs.get("shell"),
                "working-directory": attrs.get("working_directory")}
    step_env = attrs.get("env") if isinstance(attrs.get("env"), dict) else {}   # may be an expression
    literal_env = {k: str(v) for k, v in {**(job_env if isinstance(job_env, dict) else {}), **step_env}.items()
                   if isinstance(v, (str, int, float, bool)) and not EXPRESSION.search(str(v))}
    variants = [raw, rendered]
    if literal_env:
        variants.append({k: (substitute_env(v, literal_env) if k in ("run", "with", "if") else v)
                         for k, v in rendered.items()})
    return variants


def similarity(original, reduced):
    best = 0.0
    for o in original:
        ou, ru = o.get("uses"), reduced.get("uses")
        orun, rrun = o.get("run"), reduced.get("run")
        if isinstance(ou, str) and isinstance(ru, str):
            if _action_name(ou).lower() != _action_name(ru).lower():
                continue
            score = 0.85 + 0.15 * ratio(canon(o.get("with")), canon(reduced.get("with")))
        elif isinstance(orun, str) and isinstance(rrun, str):
            score = ratio(normalize(orun), normalize(rrun))
            if o.get("id") and o.get("id") == reduced.get("id"):
                score = min(1.0, score + 0.2)
            if o.get("name") and o.get("name") == reduced.get("name"):
                score = min(1.0, score + 0.1)
        elif o.get("name") and o.get("name") == reduced.get("name"):
            score = 0.5
        else:
            score = 0.0
        best = max(best, score)
    return best


def modifications(original, reduced):
    """What changed, against whichever original variant is closest; [] means unchanged."""
    best = None
    for o in original:
        kinds = []
        if isinstance(o.get("uses"), str) or isinstance(reduced.get("uses"), str):
            if _action_name(str(o.get("uses"))).lower() != _action_name(str(reduced.get("uses"))).lower():
                kinds.append("action")
            elif _action_ref(str(o.get("uses"))) != _action_ref(str(reduced.get("uses"))):
                kinds.append("action_ref")
            if canon(o.get("with")) != canon(reduced.get("with")):
                kinds.append("with")
        if normalize(o.get("run") or "") != normalize(reduced.get("run") or ""):
            kinds.append("command")
        for key, kind in (("env", "env"), ("if", "condition"), ("shell", "shell"),
                          ("working-directory", "working_directory")):
            if canon(o.get(key)) != canon(reduced.get(key)):
                # a dropped `if:` makes a conditional step unconditional: its own kind
                kinds.append("condition_removed" if key == "if" and reduced.get(key) is None else kind)
        if best is None or len(kinds) < len(best):
            best = kinds
    return best


def align(originals, reduced):
    """Order-preserving alignment maximising total similarity; pairs below the threshold do not match."""
    n, m = len(originals), len(reduced)
    sims = [[similarity(originals[i][1], reduced[j]) for j in range(m)] for i in range(n)]
    score = [[0.0] * (m + 1) for _ in range(n + 1)]
    for i in range(n - 1, -1, -1):
        for j in range(m - 1, -1, -1):
            take = sims[i][j] + score[i + 1][j + 1] if sims[i][j] >= MATCH_THRESHOLD else -1.0
            score[i][j] = max(take, score[i + 1][j], score[i][j + 1])
    pairs, i, j = [], 0, 0
    while i < n and j < m:
        if sims[i][j] >= MATCH_THRESHOLD and score[i][j] == sims[i][j] + score[i + 1][j + 1]:
            pairs.append((i, j))
            i, j = i + 1, j + 1
        elif score[i][j] == score[i + 1][j]:
            i += 1
        else:
            j += 1
    return pairs, sims


def step_list(job):
    return [s for s in (job.get("steps") or []) if isinstance(s, dict)] if isinstance(job, dict) else []


def is_setup(step):
    uses = step.get("uses")
    if isinstance(uses, str):
        return any(_action_name(uses).lower().startswith(a) for a in SETUP_ACTIONS)
    return bool(SETUP_COMMAND.search(step.get("run") or ""))


def map_reduced(analyzer, spec, reduced_yaml):
    """Reduced jobs and steps against the original graph."""
    graph = analyzer.graph
    target = spec_target_node(analyzer)
    result = {"parsed": False, "jobs": [], "steps": [], "retained_steps": set(), "retained_jobs": set()}
    if not reduced_yaml:
        result["error"] = "no YAML block in the reducer's answer"
        return result
    try:
        workflow = load_workflow_yaml(reduced_yaml)
    except Exception as e:  # noqa: BLE001
        result["error"] = f"reduced YAML does not parse: {type(e).__name__}"
        return result
    jobs = workflow.get("jobs") if isinstance(workflow, dict) else None
    if not isinstance(jobs, dict) or not jobs:
        # a bare job body (`runs-on:` / `steps:`) or a bare step list: the target job,
        # which is how the pipeline's next prompt would read it
        target_key = graph.nodes[target]["job_key"]
        if isinstance(workflow, dict) and isinstance(workflow.get("steps"), list):
            workflow = {"jobs": {target_key: workflow}}
        elif isinstance(workflow, list) and any(isinstance(s, dict) for s in workflow):
            workflow = {"jobs": {target_key: {"steps": workflow}}}
        else:
            result["error"] = "reduced YAML has no jobs or steps"
            return result
        result["shape"] = "job body without `jobs:`"
        jobs = workflow["jobs"]
    result["parsed"] = True
    result["workflow"] = workflow

    originals = {n: a for n, a in graph.nodes(data=True) if a.get("type") == "job"}
    by_key = {}
    for node, attrs in originals.items():
        by_key.setdefault(attrs["job_key"], []).append(node)
    mapped = {}
    for key, job in jobs.items():
        candidates = by_key.get(key, [])
        how = "key"
        if not candidates and isinstance(job, dict) and job.get("name"):
            candidates = [n for n, a in originals.items() if a["name"] == job["name"]]
            how = "name"
        if len(candidates) > 1:
            candidates = [target] if target in candidates else candidates[:1]
            how += " (ambiguous, took one)"
        if not candidates and len(jobs) == 1 and target not in mapped.values():
            candidates, how = [target], "only job"
        mapped[key] = candidates[0] if candidates else None
        result["jobs"].append({"reduced": key, "original": mapped[key], "how": how if candidates else "ADDED"})
    result["retained_jobs"] = {n for n in mapped.values() if n}

    for key, job in jobs.items():
        original_job = mapped[key]
        reduced_steps = step_list(job)
        if original_job is None:
            for j, step in enumerate(reduced_steps):
                result["steps"].append({"reduced_job": key, "reduced_index": j, "class": "ADDED",
                                        "setup": is_setup(step), "step": step})
            continue
        job_env = graph.nodes[original_job].get("env") or {}
        originals_in_job = sorted(((n, original_variants(a, job_env)) for n, a in graph.nodes(data=True)
                                   if a.get("type") == "step" and a["job"] == original_job),
                                  key=lambda x: graph.nodes[x[0]]["index"])
        pairs, sims = align(originals_in_job, reduced_steps)
        matched = dict((j, i) for i, j in pairs)
        for j, step in enumerate(reduced_steps):
            if j not in matched:
                result["steps"].append({"reduced_job": key, "reduced_index": j, "class": "ADDED",
                                        "setup": is_setup(step), "step": step})
                continue
            i = matched[j]
            node, variants = originals_in_job[i]
            best = sims[i][j]
            ties = sum(1 for row in sims if abs(row[j] - best) <= 0.01) if best >= MATCH_THRESHOLD else 0
            kinds = modifications(variants, step)
            entry = {"reduced_job": key, "reduced_index": j, "original": node, "similarity": round(best, 3),
                     "class": "MODIFIED" if kinds else "UNCHANGED", "changes": kinds}
            if "command" in kinds:
                entry["diff"] = command_diff(graph.nodes[node]["command"], step.get("run"))
            if "condition_removed" in kinds or "condition" in kinds:
                entry["condition"] = [str(graph.nodes[node]["raw_config"].get("if")), str(step.get("if"))]
            if ties > 1:
                entry["ambiguous"] = ties
            result["steps"].append(entry)
            result["retained_steps"].add(node)
    return result


def spec_target_node(analyzer):
    return analyzer.sliced.graph["target"]["node"]


# ── metrics ───────────────────────────────────────────────────────────────────
def produced_dependencies(analyzer):
    """(resource, consumer, class) mandatory dependencies of reproduced slice nodes that a YAML can carry."""
    sliced = analyzer.sliced
    reproduced = {n for n, a in sliced.nodes(data=True)
                  if (a.get("type") == "job" and a.get("slice_role") != "ordering_only") or a.get("type") == "step"}
    deps = []
    for consumer in reproduced:
        for resource, _, kind in analyzer.graph.in_edges(consumer, keys=True):
            if kind not in ("CONSUMES", "CONFIGURES"):
                continue
            attrs = analyzer.graph.nodes[resource]
            rtype = attrs["resource_type"]
            if rtype in ("dependency_manifest", "version_file", "matrix", "tool"):
                continue           # not representable in a workflow YAML, or scored separately (matrix)
            deps.append((resource, consumer, rtype))
    return deps


def dependency_retained(analyzer, mapping, resource, consumer, rtype):
    graph = analyzer.graph
    retained_nodes = mapping["retained_steps"] | mapping["retained_jobs"]
    owner = consumer if graph.nodes[consumer]["type"] == "job" else graph.nodes[consumer]["job"]
    if consumer not in retained_nodes or owner not in mapping["retained_jobs"]:
        return False
    producers = [u for u, _, k in graph.in_edges(resource, keys=True) if k == "PRODUCES"]
    if producers:
        return all(p in retained_nodes for p in producers)
    if mapping.get("resources") is not None:        # GWA: the resource is in its slice or not
        return resource in mapping["resources"]
    workflow = mapping.get("workflow") or {}
    reduced_job = next((workflow["jobs"][j["reduced"]] for j in mapping["jobs"] if j["original"] == owner), {})
    if rtype == "env":
        name = graph.nodes[resource]["name"]
        envs = [workflow.get("env"), reduced_job.get("env")] + [s.get("env") for s in step_list(reduced_job)]
        return any(isinstance(e, dict) and name in e for e in envs)
    if rtype == "runner":
        return bool(reduced_job.get("runs-on"))
    if rtype in ("container", "service"):
        return bool(reduced_job.get("container" if rtype == "container" else "services"))
    return True


def matrix_accuracy(analyzer, mapping):
    """correct / incorrect / unresolved / n/a for the reducer's treatment of the target's matrix."""
    graph = analyzer.graph
    target = spec_target_node(analyzer)
    assignment = analyzer.sliced.graph["target"]["matrix"] or {}
    if not graph.nodes[target].get("has_matrix") or not assignment:
        return "n/a", []
    if not mapping["parsed"] or target not in mapping["retained_jobs"]:
        return "unresolved", ["target job not in the reduced YAML"]
    workflow = mapping["workflow"]
    key = next(j["reduced"] for j in mapping["jobs"] if j["original"] == target)
    job = workflow["jobs"][key] if isinstance(workflow["jobs"][key], dict) else {}
    evidence, wrong, open_ = [], [], []
    strategy = job.get("strategy") if isinstance(job.get("strategy"), dict) else {}
    reduced_matrix = strategy.get("matrix") if isinstance(strategy.get("matrix"), dict) else None
    if reduced_matrix:
        for k, v in assignment.items():
            if k not in reduced_matrix:
                continue
            given = reduced_matrix[k]
            values = given if isinstance(given, list) else [given]
            if len(values) != 1:
                open_.append(f"{k}: still {len(values)} values")
            elif _canonical_json(values[0]) != _canonical_json(v) and str(values[0]) != str(v):
                wrong.append(f"{k}: {values[0]!r} instead of {v!r}")
            else:
                evidence.append(f"{k} = {v!r} in strategy.matrix")
    combos = graph.nodes[target].get("matrix_combinations") or []
    for entry in mapping["steps"]:
        if entry.get("original") is None or graph.nodes[entry["original"]]["job"] != target:
            continue
        raw = graph.nodes[entry["original"]]["raw_config"]
        reduced_step = step_list(job)[entry["reduced_index"]]
        text = " ".join(str(reduced_step.get(f, "")) for f in ("run", "with", "env", "if"))
        for expr in {e.strip() for t in (str(raw.get(f, "")) for f in ("run", "with", "env", "if"))
                     for e in EXPRESSION.findall(t)}:
            ref = re.fullmatch(r"matrix\.([A-Za-z0-9_-]+)", expr)
            if not ref or ref.group(1) not in assignment:
                continue
            k = ref.group(1)
            value = str(assignment[k])
            if f"matrix.{k}" in text:
                if not reduced_matrix:
                    open_.append(f"{k}: left as ${{{{ matrix.{k} }}}}")
            elif value in text:
                evidence.append(f"{k} = {value!r} in {entry['original']}")
            else:
                others = {str(c.get(k)) for c in combos if c.get(k) is not None and str(c.get(k)) != value}
                if any(o in text for o in others):
                    wrong.append(f"{k}: another combination's value in {entry['original']}")
    if wrong:
        return "incorrect", wrong
    if open_:
        return "unresolved", open_
    return ("correct", evidence) if evidence else ("not_observable", [])


def evaluate(analyzer, spec, mapping, ground_truth, method):
    graph = analyzer.graph
    sliced = analyzer.sliced
    target = spec_target_node(analyzer)
    all_steps = [n for n, a in graph.nodes(data=True) if a.get("type") == "step"]
    required_steps = {n for n, a in sliced.nodes(data=True) if a.get("type") == "step"}
    required_jobs = {n for n, a in sliced.nodes(data=True) if a.get("slice_role") in REQUIRED_ROLES}
    retained = mapping["retained_steps"]
    deps = produced_dependencies(analyzer)
    kept_deps = [d for d in deps if dependency_retained(analyzer, mapping, *d)]
    # closure: of the consumers a method keeps, how many keep their prerequisites
    retained_nodes = retained | mapping["retained_jobs"]
    closure = [d for d in deps if d[1] in retained_nodes]
    broken = [d for d in closure if d not in kept_deps]
    # a break whose producer the original run did not execute is GWA over-approximating
    broken_split = Counter()
    for resource, _, _ in broken:
        producers = [u for u, _, k in graph.in_edges(resource, keys=True) if k == "PRODUCES"]
        observed = [ground_truth[p] for p in producers if ground_truth and p in ground_truth]
        if not observed:
            broken_split["unknown"] += 1
        elif all(o == "not_executed" for o in observed):
            broken_split["producer_not_executed"] += 1
        else:
            broken_split["producer_executed"] += 1
    steps = mapping["steps"]
    aligned = [s for s in steps if s["class"] in ("UNCHANGED", "MODIFIED")]
    out = {
        "method": method,
        "required_step_recall": [len(retained & required_steps), len(required_steps)],
        "required_job_recall": [len(mapping["retained_jobs"] & required_jobs), len(required_jobs)],
        "mandatory_dependency_recall": [len(kept_deps), len(deps)],
        "dependency_closure": [len(closure) - len(broken), len(closure)],
        "broken_dependencies": [f"{c} <- {r}" for r, c, _ in broken],
        "broken_split": dict(broken_split),
        "retained_step_ratio": [len(retained), len(all_steps)],
        "modified_steps": [sum(1 for s in aligned if s["class"] == "MODIFIED"), len(aligned)],
        "added_steps": {"setup": sum(1 for s in steps if s["class"] == "ADDED" and s["setup"]),
                        "other": sum(1 for s in steps if s["class"] == "ADDED" and not s["setup"])},
        "ambiguous_steps": sum(1 for s in steps if s.get("ambiguous")),
        "dropped_dependencies": [f"{c} <- {r}" for r, c, _ in deps if (r, c, _) not in kept_deps],
    }
    if ground_truth:
        executed = {n for n, c in ground_truth.items() if c == "executed"}
        skipped = {n for n, c in ground_truth.items() if c == "not_executed"}
        out["executed_step_recall"] = [len(retained & executed), len(executed)]
        out["skipped_step_retention"] = [len(retained & skipped), len(skipped)]
    return out


def gwa_mapping(analyzer):
    """GWA's own output, in the mapping's terms: the slice, unchanged."""
    sliced = analyzer.sliced
    steps = [n for n, a in sliced.nodes(data=True) if a.get("type") == "step"]
    jobs = {n for n, a in sliced.nodes(data=True)
            if a.get("type") == "job" and a.get("slice_role") != "ordering_only"}
    return {"parsed": True, "jobs": [], "retained_steps": set(steps), "retained_jobs": jobs,
            "resources": {n for n, a in sliced.nodes(data=True) if a.get("type") == "resource"},
            "steps": [{"original": s, "class": "UNCHANGED"} for s in steps]}


def gwa_matrix_accuracy(analyzer):
    target = spec_target_node(analyzer)
    info = analyzer.sliced.graph["target"]
    if not analyzer.graph.nodes[target].get("has_matrix") or not info["matrix"]:
        return "n/a", []
    if info["resolved_by"] == "exact API name":
        return "correct", ["the job's API name is the name this assignment produces"]
    return "unverified", [f"resolved by {info['resolved_by']}"]


def scr_metrics(analyzer, ground_truth):
    """Static Condition Resolution on the target's conditional steps, against the observed run."""
    graph = analyzer.graph
    target = spec_target_node(analyzer)
    steps = [n for n, a in graph.nodes(data=True) if a.get("type") == "step" and a["job"] == target]
    conditional = [n for n in steps if graph.nodes[n]["raw_config"].get("if") is not None]
    out = {"conditional_steps": len(conditional),
           "decisions": dict(Counter(graph.nodes[n]["condition_result"] for n in conditional))}
    if ground_truth:
        out["decision_vs_run"] = dict(Counter(f"{graph.nodes[n]['condition_result']}|{ground_truth[n]}"
                                              for n in conditional if n in ground_truth))
        # a statically false step that the run executed: the one error SCR must not make
        out["false_pruning"] = [n for n in steps if graph.nodes[n].get("condition_result") == "FALSE"
                                and ground_truth.get(n) == "executed"]
    return out


def bootstrap_mean(values, iterations=10000, seed=0):
    """(mean, 2.5th, 97.5th percentile) of the mean over resampled jobs."""
    if not values:
        return None
    rng = random.Random(seed)
    means = sorted(statistics.fmean(rng.choices(values, k=len(values))) for _ in range(iterations))
    return statistics.fmean(values), means[int(0.025 * iterations)], means[int(0.975 * iterations) - 1]


def per_job(results, method, key):
    """job id -> this method's ratio for one metric, where the job has a denominator."""
    out = {}
    for r in results:
        pair = r["methods"].get(method, {}).get(key)
        if pair and pair[1]:
            out[r["id"]] = pair[0] / pair[1]
    return out


# ── disagreement analysis ─────────────────────────────────────────────────────
def disagreements(analyzer, mapping, ground_truth, matrix):
    graph = analyzer.graph
    sliced = analyzer.sliced
    target = spec_target_node(analyzer)
    issues = []
    if not mapping["parsed"]:
        return [{"category": "no_output", "detail": mapping.get("error", "")}]
    for node, attrs in sliced.nodes(data=True):
        if attrs.get("slice_role") in REQUIRED_ROLES and node not in mapping["retained_jobs"]:
            category = {"data_predecessor": "outputs", "artifact_producer": "artifacts",
                        "call_site": "reusable_workflow"}[attrs["slice_role"]]
            issues.append({"category": category, "detail": f"required job {attrs['label']} removed",
                           "node": node})
    for node, attrs in sliced.nodes(data=True):
        if attrs.get("type") != "step" or node in mapping["retained_steps"]:
            continue
        produced = {graph.nodes[r]["resource_type"] for _, r, k in graph.out_edges(node, keys=True)
                    if k == "PRODUCES"}
        consumed = any(k == "CONSUMES" for r in (r for _, r, k in graph.out_edges(node, keys=True) if k == "PRODUCES")
                       for _, _, k in graph.out_edges(r, keys=True))
        conclusion = (ground_truth or {}).get(node)
        if attrs["job"] != target:
            category = "artifacts" if "artifact" in produced else ("outputs" if consumed else "setup_prefix")
        elif conclusion == "not_executed":
            category = "conditional_step"          # the reducer dropped a step the run did not execute
        elif consumed and produced & {"job_output", "step_output", "artifact"}:
            category = "outputs"
        elif produced & {"runtime", "tool", "env_file"}:
            category = "environment"
        else:
            category = "shell_or_setup"            # executed, no explicit data edge: an implicit dependency
        issues.append({"category": category, "detail": f"step removed: {attrs['name'][:80]}", "node": node,
                       "original_run": conclusion})
    if matrix[0] in ("incorrect", "unresolved"):
        issues.append({"category": "matrix", "detail": f"{matrix[0]}: {'; '.join(matrix[1])[:200]}"})
    for entry in mapping["steps"]:
        if entry["class"] == "MODIFIED":
            detail = f"{entry['original']}: {', '.join(entry['changes'])}"
            if entry.get("condition"):
                detail += f" (if: {entry['condition'][0][:80]!r} -> {entry['condition'][1][:80]!r})"
            issues.append({"category": "modified", "detail": detail, "node": entry["original"],
                           "diff": entry.get("diff", []),
                           "original_run": (ground_truth or {}).get(entry["original"])})
        elif entry["class"] == "ADDED":
            step = entry["step"]
            what = step.get("uses") or normalize(step.get("run") or step.get("name") or "")[:80]
            issues.append({"category": "added_setup" if entry["setup"] else "invented",
                           "detail": f"{entry['reduced_job']}[{entry['reduced_index']}]: {what}"})
    return issues


# ── driver ────────────────────────────────────────────────────────────────────
def fraction(pairs):
    num = sum(p[0] for p in pairs)
    den = sum(p[1] for p in pairs)
    return f"{num}/{den} ({100 * num / den:.1f}%)" if den else "n/a"


def summarize(results, models, runs, modes):
    aligned = sum(1 for r in results if str(r["ground_truth"]).startswith("matched"))
    lines = ["# GWA vs. the YAML Reducer", "",
             f"Cases: {len(results)} dataset jobs. GWA-v1: the frozen baseline (every step of the target). "
             "GWA-v2: GWA-v1 plus Static Condition Resolution. Reducer: original prompt and settings, "
             f"{runs} run(s) per model; tables use run 0.", "",
             "- **Mode A** (`reducer:`): the deployed pipeline. The reducer is given the run's completed steps "
             "(rebuilt from its CI log) and told to keep only the target job; GWA is given neither.",
             "- **Mode B** (`reducer_B:`): input-controlled. Neither method gets completed steps or logs; "
             "both get the workflow, the repository and the matrix assignment.", "",
             "Graph-relative metrics are measured against GWA-v1's conservative slice (GWA-v1 meets them by "
             "construction; GWA-v2's pruned steps count as dropped there). Observed metrics use the steps the "
             "original run executed or skipped, recovered from its CI log: they cover the "
             f"{aligned} jobs whose log aligns with the workflow unambiguously, and are reconstructed labels, "
             "not a complete execution trace.", ""]
    methods = ["gwa_v1", "gwa_v2"] + [f"{prefix}:{m}" for prefix, mode in (("reducer", "A"), ("reducer_B", "B"))
                                      if mode in modes for m in models]
    reducers = [m for m in methods if m.startswith("reducer")]
    rows = [("required-step recall (graph-relative)", "required_step_recall"),
            ("required-job recall (graph-relative)", "required_job_recall"),
            ("mandatory dependency recall (graph-relative)", "mandatory_dependency_recall"),
            ("dependency closure of retained steps (graph-relative)", "dependency_closure"),
            ("observed executed-step recall", "executed_step_recall"),
            ("observed skipped-step retention (lower is better)", "skipped_step_retention"),
            ("retained-step ratio (of all workflow steps)", "retained_step_ratio"),
            ("step modification rate (of aligned steps)", "modified_steps")]
    lines += ["| metric | " + " | ".join(methods) + " |", "|---|" + "---|" * len(methods)]
    for title, key in rows:
        cells = []
        for method in methods:
            pairs = [r["methods"][method][key] for r in results if method in r["methods"]
                     and key in r["methods"][method]]
            cells.append(fraction(pairs))
        lines.append(f"| {title} | " + " | ".join(cells) + " |")
    def added(ms):
        return f"{sum(x['added_steps']['setup'] for x in ms)} / {sum(x['added_steps']['other'] for x in ms)}"

    def ambiguous(ms):
        return str(sum(x["ambiguous_steps"] for x in ms))

    def broken(ms):
        split = Counter()
        for x in ms:
            split.update(x.get("broken_split", {}))
        return (f"{split['producer_executed']} / {split['producer_not_executed']} / {split['unknown']}"
                if split else "0")

    def modification_kinds(ms):
        kinds = Counter(k for x in ms for s in x.get("step_mapping", []) if s["class"] == "MODIFIED"
                        for k in s["changes"])
        return ", ".join(f"{k} {n}" for k, n in kinds.most_common()) or "—"

    for title, fn in (("added steps: setup / other", added), ("ambiguous step mappings", ambiguous),
                      ("broken dependencies: producer ran / did not run / no ground truth", broken),
                      ("modifications by kind", modification_kinds)):
        cells = [fn([r["methods"][method] for r in results if method in r["methods"]]) for method in methods]
        lines.append(f"| {title} | " + " | ".join(cells) + " |")
    lines += ["", "## Matrix assignment", "", "| outcome | " + " | ".join(methods) + " |",
              "|---|" + "---|" * len(methods)]
    outcomes = ("correct", "incorrect", "unresolved", "unverified", "not_observable", "n/a")
    for outcome in outcomes:
        lines.append(f"| {outcome} | " + " | ".join(
            str(sum(1 for r in results if r["methods"].get(method, {}).get("matrix") == outcome)) for method in methods) + " |")
    lines += ["", "## Cost", "",
              "| method | input tokens | output tokens | USD (list price) | USD (pipeline's table) | "
              "seconds (total) | unparsable outputs |", "|---|---|---|---|---|---|---|"]
    for method in methods:
        ms = [r["methods"][method] for r in results if method in r["methods"]]
        cost = [m.get("cost", {}) for m in ms]
        tokens_in = sum(c.get("input_tokens", 0) for c in cost)
        tokens_out = sum(c.get("output_tokens", 0) for c in cost)
        price = LIST_PRICE.get(method.split(":", 1)[-1], (0.0, 0.0))
        lines.append(f"| {method} | {tokens_in} | {tokens_out} | "
                     f"{(tokens_in * price[0] + tokens_out * price[1]) / 1e6:.4f} | "
                     f"{sum(c.get('cost_usd', 0) for c in cost):.4f} | "
                     f"{sum(c.get('seconds', 0) for c in cost):.1f} | "
                     f"{sum(1 for m in ms if not m.get('parsed', True))} |")
    # ── Static Condition Resolution ──
    scr = [r["methods"]["gwa_v2"]["scr"] for r in results if "scr" in r["methods"].get("gwa_v2", {})]
    decisions = Counter()
    versus = Counter()
    for s in scr:
        decisions.update(s["decisions"])
        versus.update(s.get("decision_vs_run", {}))
    conditional = sum(s["conditional_steps"] for s in scr)
    false_pruning = [p for s in scr for p in s.get("false_pruning", [])]
    false_observed = versus["FALSE|executed"] + versus["FALSE|not_executed"]
    lines += ["", "## Static Condition Resolution (GWA-v2, target-job steps with an `if:`)", "",
              f"{conditional} conditional steps: TRUE {decisions['TRUE']}, FALSE {decisions['FALSE']}, "
              f"UNKNOWN {decisions['UNKNOWN']} — decision coverage "
              f"{100 * (decisions['TRUE'] + decisions['FALSE']) / conditional:.1f}%." if conditional else
              "No conditional steps.", "",
              "| decision | observed executed | observed not executed |", "|---|---|---|"]
    for decision in ("TRUE", "FALSE", "UNKNOWN"):
        lines.append(f"| {decision} | {versus[f'{decision}|executed']} | {versus[f'{decision}|not_executed']} |")
    lines += ["", f"FALSE decisions confirmed by the run: {versus['FALSE|not_executed']}/{false_observed}"
                  + (f" ({100 * versus['FALSE|not_executed'] / false_observed:.1f}%)" if false_observed else "")
                  + f". **False pruning (FALSE but executed): {len(false_pruning)}**"
                  + (f": {', '.join(false_pruning)}" if false_pruning else "") + ".",
              "A TRUE step that did not run is expected: TRUE is about the expression, and earlier "
              "failures or an implicit `success()` can still prevent the step."]

    # ── paired per-job statistics ──
    keys = (("observed executed-step recall", "executed_step_recall"),
            ("observed skipped-step retention", "skipped_step_retention"),
            ("required-step recall (graph-relative)", "required_step_recall"),
            ("retained-step ratio", "retained_step_ratio"))
    lines += ["", "## Per-job means with 95% bootstrap intervals", "",
              "Each job counts once (10,000 resamples of jobs).", "",
              "| metric | " + " | ".join(methods) + " |", "|---|" + "---|" * len(methods)]
    for title, key in keys:
        cells = []
        for method in methods:
            stats = bootstrap_mean(list(per_job(results, method, key).values()))
            cells.append(f"{stats[0]:.3f} [{stats[1]:.3f}, {stats[2]:.3f}] (n={len(per_job(results, method, key))})"
                         if stats else "n/a")
        lines.append(f"| {title} | " + " | ".join(cells) + " |")
    pairs = [("gwa_v2", "gwa_v1")] + [("gwa_v2", m) for m in reducers] + \
            [(a, b) for a in reducers if a.startswith("reducer:") for b in reducers
             if b.startswith("reducer_B:") and a.split(":", 1)[1] == b.split(":", 1)[1]]
    lines += ["", "## Paired per-job differences (first minus second), 95% bootstrap intervals", "",
              "| metric | " + " | ".join(f"{a} − {b}" for a, b in pairs) + " |", "|---|" + "---|" * len(pairs)]
    for title, key in keys:
        cells = []
        for a, b in pairs:
            ra, rb = per_job(results, a, key), per_job(results, b, key)
            diffs = [ra[j] - rb[j] for j in ra if j in rb]
            stats = bootstrap_mean(diffs)
            cells.append(f"{stats[0]:+.3f} [{stats[1]:+.3f}, {stats[2]:+.3f}] (n={len(diffs)})" if stats else "n/a")
        lines.append(f"| {title} | " + " | ".join(cells) + " |")

    lines += ["", "## Disagreement categories (reducer vs. GWA-v1)", "",
              "| category | " + " | ".join(reducers) + " | cases |", "|---|" + "---|" * (len(reducers) + 1)]
    categories = {issue["category"] for r in results for method in reducers
                  for issue in r["methods"].get(method, {}).get("issues", [])}
    for category in sorted(categories):
        counts = [sum(1 for r in results for i in r["methods"].get(m, {}).get("issues", []) if i["category"] == category)
                  for m in reducers]
        cases = sum(1 for r in results if any(i["category"] == category for m in reducers
                                              for i in r["methods"].get(m, {}).get("issues", [])))
        lines.append(f"| {category} | " + " | ".join(map(str, counts)) + f" | {cases} |")
    if runs > 1:
        lines += ["", "## Run-to-run variability", "", "| model | metric | mean | stdev | per run |", "|---|---|---|---|---|"]
        for model in models:
            for title, key in rows[:5]:
                per_run = []
                for run in range(runs):
                    pairs = [r["runs"][f"reducer:{model}"][run][key] for r in results
                             if len(r.get("runs", {}).get(f"reducer:{model}", [])) > run
                             and key in r["runs"][f"reducer:{model}"][run]]
                    den = sum(p[1] for p in pairs)
                    if den:
                        per_run.append(sum(p[0] for p in pairs) / den)
                if len(per_run) > 1:
                    lines.append(f"| {model} | {title} | {statistics.mean(per_run):.3f} | "
                                 f"{statistics.stdev(per_run):.3f} | {', '.join(f'{x:.3f}' for x in per_run)} |")
    return "\n".join(lines) + "\n"


def write_settings(args):
    """Everything needed to reproduce this comparison, beside each answer's prompt hash."""
    import hashlib

    def digest(path):
        with open(path, "rb") as f:
            return hashlib.sha256(f.read()).hexdigest()

    settings = {
        "reducer": {
            "prompt_function": "prompts.yaml_reducer_prompt",
            "calls": {"claude-haiku-4-5-20251001": "llm4build-pipeline.call_claude (temperature 0.0, max_tokens 4096)",
                      "gpt4o": "llm4build-pipeline.call_openai (model gpt-4o, temperature 0.0)"},
            "output_extraction": YAML_BLOCK.pattern,
            "inputs": "workflow file as the pipeline selects it; API job name; mat_k from job.generate_input_file; "
                      "completed steps rebuilt from the original CI log (Set up job, executed steps named as the "
                      "API names them, Complete job; post-steps omitted)",
            "models_run": args.models, "runs": args.runs,
            "modes": {"A": "completed steps given (the deployed pipeline)",
                      "B": "input-controlled: no completed steps"},
            "modes_run": args.modes,
        },
        "gwa": {"gwa_v1": "frozen/gwa_v1 (conditions off)",
                "gwa_v2": "repository gwa.py with Static Condition Resolution (conditions static)",
                "semantics": "target_execution",
                "inputs": "workflow, repository, API job (name, labels) and run (event, branch, pull requests); "
                          "never the CI log"},
        "mapping": {"match_threshold": MATCH_THRESHOLD,
                    "equivalent_renderings": "as written; matrix-rendered; literal env substituted; scalars compared "
                                             "as strings; full-line shell comments ignored"},
        "ground_truth": {"source": "original CI log `##[group]Run` headers",
                         "alignment": "order-preserving, maximising header scores (3 exact, 2 literal prefix, "
                                      "1 fuzzy >= 0.8); uncertain if an unconditional step is unmatched before the "
                                      "last match (or anywhere in a successful job), or a header fits an executed "
                                      "and an unexecuted step equally"},
        "file_sha256": {name: digest(os.path.join(root, name)) for root, name in (
            (ROOT, "llm4build-pipeline.py"), (ROOT, "prompts.py"), (HERE, "gwa_vs_reducer.py"),
            (FROZEN, "gwa.py"), (FROZEN, "gwa_validation.py"), (HERE, "cases.json"))} | {
            f"v2/{name}": digest(os.path.join(ROOT, name)) for name in ("gwa.py", "gwa_conditions.py", "gwa_validation.py")},
    }
    with open(os.path.join(OUT, "settings.json"), "w") as f:
        json.dump(settings, f, indent=1)


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--models", nargs="+", default=list(MODELS), choices=list(MODELS))
    parser.add_argument("--runs", type=int, default=1)
    parser.add_argument("--modes", nargs="+", default=["A", "B"], choices=["A", "B"],
                        help="A: the reducer gets the run's completed steps (the deployed pipeline); "
                             "B: input-controlled, no completed steps")
    parser.add_argument("--only", nargs="*")
    parser.add_argument("--estimate", action="store_true")
    parser.add_argument("--sample-agreements", type=float, default=0.2,
                        help="fraction of cases without disagreements added to the inspection sample")
    parser.add_argument("--seed", type=int, default=0)
    args = parser.parse_args()

    os.makedirs(OUT, exist_ok=True)
    cases = [c for c in json.load(open(os.path.join(HERE, "cases.json")))
             if c.get("kind") == "dataset" and not c.get("error") and (not args.only or c["id"] in args.only)]
    conclusions = job_conclusions(cases)

    def prepare(case):
        analyzer, spec, seconds = run_version(GWA_V1, case)
        truth, note = observed_steps(analyzer, log_headers(case), conclusions.get(case["id"]))
        return analyzer, spec, seconds, truth, note, completed_steps(analyzer, truth)

    if args.estimate:
        prepared = [prepare(c) for c in cases]
        chars = sum(len(reducer_prompt(c, p[5])) for c, p in zip(cases, prepared))
        notes = Counter(p[4].split(":")[0].split(" (")[0] for p in prepared)
        print(f"ground truth from original logs: {dict(notes)}")
        tokens = chars / 3.5
        print(f"{len(cases)} cases, ~{tokens:,.0f} prompt tokens per model and run")
        for model in args.models:
            price = LIST_PRICE[model]
            print(f"  {model}: ~${(tokens * price[0] + len(cases) * 1500 * price[1]) / 1e6 * args.runs:.2f} "
                  f"for {args.runs} run(s) at list price (assuming ~1,500 output tokens per answer)")
        return

    pipeline = None
    results = []
    for case in cases:
        analyzer, spec, gwa_seconds, truth, truth_note, completed = prepare(case)
        record = {"id": case["id"], "repo": case["repo"], "job_url": case.get("job_url"),
                  "target": spec["target"], "job_conclusion": conclusions.get(case["id"]),
                  "ground_truth": truth_note, "completed_steps_given": len(completed), "methods": {}, "runs": {}}
        record["methods"]["gwa_v1"] = {**evaluate(analyzer, spec, gwa_mapping(analyzer), truth, "gwa_v1"),
                                       "matrix": gwa_matrix_accuracy(analyzer)[0],
                                       "cost": {"input_tokens": 0, "output_tokens": 0, "cost_usd": 0.0,
                                                "seconds": round(gwa_seconds, 2)}}
        # GWA-v2 is scored against the same reference (GWA-v1's graph and slice); step ids are shared
        analyzer_v2, spec_v2, seconds_v2 = run_version(GWA_V2, case)
        record["methods"]["gwa_v2"] = {**evaluate(analyzer, spec, gwa_mapping(analyzer_v2), truth, "gwa_v2"),
                                       "matrix": gwa_matrix_accuracy(analyzer_v2)[0],
                                       "scr": scr_metrics(analyzer_v2, truth),
                                       "pruned_steps": [f"{p['job']}:{p['index']}" for p in
                                                        spec_v2["execution_slice"]["pruned_steps"]],
                                       "diagnostics": spec_v2["execution_slice"]["diagnostics"],
                                       "cost": {"input_tokens": 0, "output_tokens": 0, "cost_usd": 0.0,
                                                "seconds": round(seconds_v2, 2)}}
        record["completed_steps_given"] = {"A": len(completed), "B": 0}
        for mode, model in ((mode, model) for mode in args.modes for model in args.models):
            key, folder, given = {"A": ("reducer", "reducer", completed),
                                  "B": ("reducer_B", "reducer_input_controlled", [])}[mode]
            per_run = []
            for run in range(args.runs):
                cache = os.path.join(OUT, folder, model, f"run{run}", f"{case['id']}.json")
                prompt = reducer_prompt(case, given)
                prompt_hash = __import__("hashlib").sha256(prompt.encode()).hexdigest()
                output = json.load(open(cache)) if os.path.exists(cache) else None
                if output is None or output.get("prompt_sha256") != prompt_hash:   # new or stale input
                    pipeline = pipeline or load_pipeline()
                    output = run_reducer(pipeline, model, prompt)
                    output["prompt_sha256"] = prompt_hash
                    output["completed_steps"] = [s["name"] for s in given]
                    os.makedirs(os.path.dirname(cache), exist_ok=True)
                    with open(cache, "w") as f:
                        json.dump(output, f, indent=1)
                mapping = map_reduced(analyzer, spec, output["reduced_yaml"])
                matrix = matrix_accuracy(analyzer, mapping)
                metrics = {**evaluate(analyzer, spec, mapping, truth, f"{key}:{model}"),
                           "parsed": mapping["parsed"], "shape": mapping.get("shape", "workflow"),
                           "matrix": matrix[0], "matrix_evidence": matrix[1],
                           "job_mapping": mapping["jobs"],
                           "step_mapping": [{k: v for k, v in s.items() if k != "step"} for s in mapping["steps"]],
                           "issues": disagreements(analyzer, mapping, truth, matrix),
                           "cost": {k: output[k] for k in ("input_tokens", "output_tokens", "cost_usd", "seconds")}}
                if mapping.get("error"):
                    metrics["error"] = mapping["error"]
                per_run.append(metrics)
            record["methods"][f"{key}:{model}"] = per_run[0]
            record["runs"][f"{key}:{model}"] = per_run
        results.append(record)
        print(json.dumps({"id": case["id"], **{m: {"steps": v["required_step_recall"], "matrix": v["matrix"],
                                                    "issues": len(v.get("issues", []))}
                                                for m, v in record["methods"].items()}}), flush=True)

    with open(os.path.join(OUT, "results.json"), "w") as f:
        json.dump(results, f, indent=1, default=str)
    write_settings(args)
    with open(os.path.join(OUT, "summary.md"), "w") as f:
        f.write(summarize(results, args.models, args.runs, args.modes))

    # disagreements, and the inspection sample: every disagreeing case plus a share of agreeing ones
    rng = random.Random(args.seed)
    blocking = {"outputs", "artifacts", "reusable_workflow", "shell_or_setup", "environment", "setup_prefix",
                "matrix", "invented", "no_output", "modified"}
    disagreeing = [r for r in results if any(i["category"] in blocking for m, v in r["methods"].items()
                                             for i in v.get("issues", []))]
    agreeing = [r for r in results if r not in disagreeing]
    sample = disagreeing + rng.sample(agreeing, round(len(agreeing) * args.sample_agreements))
    lines = ["# Reducer disagreements", "",
             f"{len(disagreeing)} of {len(results)} cases have a disagreement other than dropping skipped "
             f"steps or adding setup steps; {len(sample) - len(disagreeing)} agreeing cases are sampled too.", ""]
    rows = []
    for r in sorted(sample, key=lambda r: r["id"]):
        lines += [f"## {r['id']}", "", f"- [job]({r['job_url']}) — target `{r['target']['yaml_job_id']}`, "
                                       f"matrix `{json.dumps(r['target']['matrix'])}`; ground truth: {r['ground_truth']}"]
        for method, v in r["methods"].items():
            if method.startswith("gwa"):
                continue
            lines.append(f"- **{method}**: matrix {v['matrix']}; required steps "
                         f"{v['required_step_recall'][0]}/{v['required_step_recall'][1]}; "
                         f"modified {v['modified_steps'][0]}; added {v['added_steps']}")
            for issue in v["issues"]:
                lines.append(f"  - `{issue['category']}` {issue['detail']}"
                             + (f" (original run: {issue['original_run']})" if issue.get("original_run") else ""))
                if issue.get("diff"):
                    lines += ["    ```diff"] + [f"    {d[:160]}" for d in issue["diff"]] + ["    ```"]
                rows.append({"case": r["id"], "method": method, "category": issue["category"],
                             "detail": issue["detail"], "original_run": issue.get("original_run") or "",
                             "sample": "disagreement" if r in disagreeing else "agreement",
                             "verdict": "", "notes": ""})
            if not v["issues"]:
                rows.append({"case": r["id"], "method": method, "category": "agreement", "detail": "",
                             "original_run": "", "sample": "agreement", "verdict": "", "notes": ""})
        lines.append("")
    with open(os.path.join(OUT, "disagreements.md"), "w") as f:
        f.write("\n".join(lines) + "\n")
    with open(os.path.join(OUT, "inspection.csv"), "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["case", "method", "category", "detail", "original_run", "sample",
                                               "verdict", "notes"])
        writer.writeheader()
        writer.writerows(rows)
    print(f"{len(results)} cases -> {OUT}; {len(disagreeing)} with disagreements; inspection sample {len(sample)}")


if __name__ == "__main__":
    main()
