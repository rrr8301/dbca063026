"""Semantic validation of a GWA slice.

Every check returns pass / warn / fail with the offending items. The report
goes into the execution specification as `validation`, so a slice that
breaks an invariant is flagged instead of being used silently. The checks
read the full graph, the sliced graph and the specification -- never the YAML.

  target_resolution        the target's matrix assignment is one its job expands to
  matrix_rendering         no plain `${{ matrix.* }}` left in the reproduced target
  reusable_workflow        a called target keeps its call site; consumed inputs have values;
                           local composite actions were found and their inputs bound
  conditions               needs.X references name a needed job; steps.S an earlier step
  artifacts                every consumed artifact keeps its producer, ordered before it
  dependency_preservation  every mandatory dependency of a reproduced node is in the slice
  step_ordering            kept steps are all (target) or a prefix; spec order is topological
  graph_spec_consistency   the specification lists exactly the sliced graph's contents
  justification            every retained node has a reason and a path to the target
  dynamic_references       the `${{ }}` expressions left in the specification, by context
"""
import re
from collections import Counter

import networkx as nx

from .gwa import (EXPRESSION, JOB_FIELDS, STEP_FIELDS, STEP_OUTPUT, STEP_STATUS, _canonical_json,
                 _expression_text, _strings)

NEEDS_REF = re.compile(r"\bneeds\.([A-Za-z0-9_-]+)\.(?:outputs|result)\b")
PLAIN_MATRIX = re.compile(r"^\s*matrix\.[A-Za-z0-9_.-]+\s*$")
REACH_EDGES = {"NEEDS", "PRODUCES", "CONSUMES", "CONFIGURES", "PRECEDES", "CONTAINS", "CALLS"}
# The edges that may justify a retained job, by role: a job kept for its data
# must reach the target through data flow, not merely through `needs:`.
DATA_PATH = {"PRODUCES", "CONSUMES", "CONFIGURES", "PRECEDES", "CONTAINS", "CALLS"}
JUSTIFYING_EDGES = {
    "data_predecessor": DATA_PATH,
    "artifact_producer": DATA_PATH,
    "call_site": DATA_PATH,
    "ordering_only": {"NEEDS"},
    "control_predecessor": {"NEEDS"},
}
JOB_EXECUTION_FIELDS = ("runs_on", "container", "services", "env", "condition", "defaults_run",
                        "call_with")
STEP_EXECUTION_FIELDS = ("command", "uses", "with_", "env", "working_directory", "shell",
                         "condition", "expanded_steps")
CONTEXTS = {"github", "env", "secrets", "vars", "runner", "steps", "needs", "inputs", "matrix",
            "job", "jobs", "strategy"}
STATUS_ORDER = {"pass": 0, "warn": 1, "fail": 2}


def _of_type(graph, kind):
    return [n for n, a in graph.nodes(data=True) if a.get("type") == kind]


def _owner(graph, node):
    attrs = graph.nodes[node]
    return node if attrs.get("type") == "job" else attrs.get("job")


def _producers(graph, resource):
    return [u for u, _, k in graph.in_edges(resource, keys=True) if k == "PRODUCES"]


def validate_slice(graph, sliced, spec):
    target_info = sliced.graph["target"]
    target = target_info["node"]
    jobs = _of_type(sliced, "job")
    reproduced = [j for j in jobs if sliced.nodes[j].get("slice_role") != "ordering_only"]
    steps = _of_type(sliced, "step")
    target_steps = [s for s in steps if sliced.nodes[s]["job"] == target]
    unresolved_kinds = {u["kind"] for u in spec["unresolved_dependencies"]}
    needs_graph = nx.DiGraph((u, v) for u, v, k in graph.edges(keys=True) if k == "NEEDS")
    label = {j: graph.nodes[j]["label"] for j in _of_type(graph, "job")}
    results = {}

    def record(name, failures=(), warnings=(), **details):
        status = "fail" if failures else ("warn" if warnings else "pass")
        results[name] = {"status": status, **details}
        if failures:
            results[name]["failures"] = list(failures)
        if warnings:
            results[name]["warnings"] = list(warnings)

    # ── target_resolution ─────────────────────────────────────────────────────
    failures, warnings = [], []
    job = graph.nodes[target]
    assigned = target_info["matrix"] or {}
    if target_info["resolved_by"] != "exact API name":
        warnings.append(f"resolved by {target_info['resolved_by']}, not by the exact API name")
    if job.get("has_matrix"):
        combinations = job.get("matrix_combinations")
        if combinations is None:
            warnings.append("the matrix is computed at runtime; the assignment is "
                            + ("from the job config" if assigned else "unknown"))
        elif _canonical_json(assigned) not in {_canonical_json(c) for c in combinations}:
            failures.append(f"matrix {assigned} is not one of the job's {len(combinations)} combinations")
    record("target_resolution", failures, warnings, resolved_by=target_info["resolved_by"],
           matrix=assigned)

    # ── matrix_rendering ──────────────────────────────────────────────────────
    plain, complex_ = [], []
    for node in [target] + target_steps:
        attrs = sliced.nodes[node]
        fields = JOB_EXECUTION_FIELDS if attrs["type"] == "job" else STEP_EXECUTION_FIELDS
        for field in fields:
            for text in _strings(attrs.get(field)):
                for expr in EXPRESSION.findall(text):
                    if PLAIN_MATRIX.match(expr):
                        plain.append(f"{node}.{field}: ${{{{ {expr.strip()} }}}}")
                    elif "matrix." in expr:
                        complex_.append(f"{node}.{field}: ${{{{ {expr.strip()[:80]} }}}}")
    record("matrix_rendering",
           failures=plain if plain and "matrix" not in unresolved_kinds else [],
           warnings=(plain if "matrix" in unresolved_kinds else []) + complex_,
           # keys the assignment lacks: rendered "", as GitHub evaluates them
           rendered_empty=sliced.nodes[target].get("matrix_rendered_empty", []))

    # ── reusable_workflow (and local composite actions) ───────────────────────
    failures, warnings = [], []
    workflow = next((u for u, _, k in graph.in_edges(target, keys=True) if k == "CONTAINS"), None)
    if target_info["scope"]:
        caller = next((u for u, _, k in graph.in_edges(workflow, keys=True) if k == "CALLS"), None)
        if caller is None:
            failures.append("the target is in a called workflow but no job calls it")
        elif caller not in sliced or sliced.nodes[caller].get("slice_role") != "call_site":
            failures.append(f"call site {caller} is not in the slice as call_site")
        elif not (sliced.has_edge(caller, workflow) and sliced.has_edge(workflow, target)):
            failures.append("the CALLS/CONTAINS path from the call site to the target is not kept")
    for resource in (n for n, a in sliced.nodes(data=True) if a.get("resource_type") == "input"):
        name = sliced.nodes[resource]["name"]
        if any(p in sliced for p in _producers(graph, resource)):
            continue
        consumers = [v for _, v, k in sliced.out_edges(resource, keys=True) if k == "CONSUMES"]
        containing = {next((u for u, _, k in graph.in_edges(_owner(graph, c), keys=True)
                            if k == "CONTAINS"), None) for c in consumers}
        if any("default" in (graph.nodes[w].get("declared_inputs", {}).get(name) or {})
               for w in containing if w):
            continue
        (warnings if "input" in unresolved_kinds else failures).append(
            f"inputs.{name} has no caller value or default"
            + ("" if "input" in unresolved_kinds else " and is not reported as unresolved"))
    for step in steps:
        attrs = sliced.nodes[step]
        if attrs["role"] == "local_action":
            if (attrs["action"] or {}).get("kind") == "missing":
                warnings.append(f"{step}: local action {attrs['uses']} not found")
            unbound = sorted({e.strip() for t in _strings(attrs["expanded_steps"])
                              for e in EXPRESSION.findall(t) if e.strip().startswith("inputs.")})
            if unbound:
                warnings.append(f"{step}: composite action inputs without a value: {unbound}")
    record("reusable_workflow", failures, warnings, applies=bool(target_info["scope"]))

    # ── conditions ────────────────────────────────────────────────────────────
    failures, warnings = [], []
    for job_node in reproduced:
        attrs = sliced.nodes[job_node]
        needed = {str(n) for n in attrs["needs"]}
        texts = [(job_node, f, _expression_text(f, attrs["raw_config"][f]))
                 for f in JOB_FIELDS if attrs["raw_config"].get(f) is not None]
        for step in (s for s in steps if sliced.nodes[s]["job"] == job_node):
            raw = sliced.nodes[step]["raw_config"]
            texts += [(step, f, _expression_text(f, raw[f])) for f in STEP_FIELDS if raw.get(f) is not None]
        for node, field, text in texts:
            for referenced in sorted(set(NEEDS_REF.findall(text)) - needed):
                failures.append(f"{node}.{field} uses needs.{referenced} but {attrs['label']} "
                                f"does not need {referenced}")
            if not node.startswith("step:"):
                continue
            index = sliced.nodes[node]["index"]
            ids = {s for s, _ in STEP_OUTPUT.findall(text)} | set(STEP_STATUS.findall(text))
            for step_id in sorted(ids):
                producer = next((s for s, a in graph.nodes(data=True) if a.get("type") == "step"
                                 and a["job"] == job_node and a.get("step_id") == step_id), None)
                if producer is None:
                    warnings.append(f"{node}.{field}: no step with id {step_id!r}")
                elif graph.nodes[producer]["index"] >= index:
                    failures.append(f"{node}.{field} reads steps.{step_id}, which runs later")
    record("conditions", failures, warnings)

    # ── artifacts ─────────────────────────────────────────────────────────────
    failures, warnings, transfers = [], [], 0
    for resource in (n for n, a in sliced.nodes(data=True) if a.get("resource_type") == "artifact"):
        consumers = [v for _, v, k in sliced.out_edges(resource, keys=True) if k == "CONSUMES"]
        all_producers = _producers(graph, resource)
        kept = [p for p in all_producers if p in sliced]
        if consumers and not kept:
            failures.append(f"{resource} is consumed but no producer is kept")
        if set(all_producers) - set(kept):
            failures.append(f"{resource}: producers dropped: {sorted(set(all_producers) - set(kept))}")
        for producer in kept:
            for consumer in consumers:
                p_job, c_job = _owner(sliced, producer), _owner(sliced, consumer)
                if p_job == c_job:
                    continue
                transfers += 1
                if c_job not in needs_graph or p_job not in nx.ancestors(needs_graph, c_job):
                    warnings.append(f"{resource}: {label[c_job]} does not need {label[p_job]}, so "
                                    f"the original workflow does not order the upload first")
    for step in steps:
        if sliced.nodes[step]["role"] == "artifact_download" and not any(
                k == "CONSUMES" and sliced.nodes[u].get("resource_type") == "artifact"
                for u, _, k in sliced.in_edges(step, keys=True)):
            warnings.append(f"{step}: downloads an artifact no job in this workflow uploads")
    record("artifacts", failures, warnings, cross_job_transfers=transfers)

    # ── dependency_preservation ───────────────────────────────────────────────
    total, preserved, missing = 0, 0, []
    by_class = Counter()
    for node in reproduced + steps:
        for resource, _, kind in graph.in_edges(node, keys=True):
            if kind not in ("CONSUMES", "CONFIGURES"):
                continue
            total += 1
            ok = resource in sliced and all(p in sliced for p in _producers(graph, resource))
            preserved += ok
            by_class[graph.edges[resource, node, kind]["dependency"]] += 1
            if not ok:
                missing.append(f"{node} <-{kind}- {resource}")
        if node.startswith("step:"):
            for previous, _, kind in graph.in_edges(node, keys=True):
                if kind == "PRECEDES":
                    total += 1
                    preserved += previous in sliced
                    by_class["order"] += 1
                    if previous not in sliced:
                        missing.append(f"{node} <-PRECEDES- {previous}")
    record("dependency_preservation", failures=missing, preserved=preserved, total=total,
           by_class=dict(by_class))

    # ── step_ordering ─────────────────────────────────────────────────────────
    failures = []
    for job_node in reproduced:
        role = sliced.nodes[job_node].get("slice_role")
        every = sorted(graph.nodes[s]["index"] for s in _of_type(graph, "step")
                       if graph.nodes[s]["job"] == job_node)
        kept = sorted(sliced.nodes[s]["index"] for s in steps if sliced.nodes[s]["job"] == job_node)
        if role in ("target", "control_predecessor") and kept != every:
            failures.append(f"{label[job_node]}: {role} keeps steps {kept}, not all {every}")
        elif role not in ("target", "control_predecessor") and kept != list(range(len(kept))):
            failures.append(f"{label[job_node]}: kept steps {kept} are not a prefix")
    job_order = [j["job"] for j in spec["execution_slice"]["jobs"]]
    position = {name: i for i, name in enumerate(job_order)}
    listed = [(s["job"], s["index"]) for s in spec["execution_slice"]["steps"]]
    if listed != sorted(listed, key=lambda s: (position.get(s[0], len(position)), s[1])):
        failures.append("specification steps are not grouped by job order and sorted by index")
    def listed_after(later, earlier):
        # jobs missing from the specification are graph_spec_consistency's to report
        return later in position and earlier in position and position[later] < position[earlier]

    for u, v, kind in sliced.edges(keys=True):
        if kind == "NEEDS" and listed_after(label[v], label[u]):
            failures.append(f"{label[v]} is listed before {label[u]}, which it needs")
    for crossing in spec["execution_slice"]["required_outputs"] + spec["execution_slice"]["required_artifacts"]:
        if crossing["producer"] not in graph or crossing["consumer"] not in graph:
            failures.append(f"{crossing['resource']}: producer or consumer is not in the graph")
            continue
        p_job, c_job = _owner(graph, crossing["producer"]), _owner(graph, crossing["consumer"])
        if listed_after(label[c_job], label[p_job]):
            failures.append(f"{label[c_job]} is listed before {label[p_job]}, whose "
                            f"{crossing['resource']} it consumes")
    record("step_ordering", failures, job_order=job_order)

    # ── graph_spec_consistency ────────────────────────────────────────────────
    failures = []
    sl = spec["execution_slice"]

    def compare(what, from_graph, from_spec):
        if from_graph != from_spec:
            failures.append(f"{what}: only in graph {sorted(from_graph - from_spec)[:5]}, "
                            f"only in spec {sorted(from_spec - from_graph)[:5]}")

    compare("jobs", {(label[j], sliced.nodes[j].get("slice_role")) for j in jobs},
            {(j["job"], j["role"]) for j in sl["jobs"]})
    compare("steps", {(sliced.nodes[s]["job_label"], sliced.nodes[s]["index"]) for s in steps},
            {(s["job"], s["index"]) for s in sl["steps"]})
    compare("runtimes", {sliced.nodes[n]["source"] + "|" + str(sliced.nodes[n]["runtime"])
                         for n, a in sliced.nodes(data=True) if a.get("resource_type") == "runtime"},
            {r["source"] + "|" + str(r["runtime"]) for r in spec["environment_constraints"]["runtimes"]})
    compare("dependency_files", {a["path"] for _, a in sliced.nodes(data=True)
                                 if a.get("resource_type") in ("dependency_manifest", "version_file")},
            {f["path"] for f in spec["environment_constraints"]["dependency_files"]})
    crossings = set()
    for resource, attrs in sliced.nodes(data=True):
        if attrs.get("resource_type") in ("job_output", "artifact"):
            for p in (p for p in _producers(sliced, resource)):
                for _, c, k in sliced.out_edges(resource, keys=True):
                    if k == "CONSUMES" and _owner(sliced, p) != _owner(sliced, c):
                        crossings.add((resource[len("resource:"):], p, c))
    compare("required outputs and artifacts", crossings,
            {(x["resource"], x["producer"], x["consumer"])
             for x in sl["required_outputs"] + sl["required_artifacts"]})
    compare("ordering_constraints", {(label[u], label[v]) for u, v, k in sliced.edges(keys=True)
                                     if k == "NEEDS" and v in reproduced},
            {(c["before"], c["after"]) for c in sl["ordering_constraints"]})
    record("graph_spec_consistency", failures)

    # ── justification ─────────────────────────────────────────────────────────
    failures = []
    sink = "__target__"
    reach_by_edges = {}

    def reach_graph(edge_types):
        key = frozenset(edge_types)
        if key not in reach_by_edges:
            reach = nx.DiGraph((u, v) for u, v, k in sliced.edges(keys=True) if k in edge_types)
            reach.add_edges_from((n, sink) for n in [target] + target_steps)
            reach_by_edges[key] = reach
        return reach_by_edges[key]

    paths = {}
    for node, attrs in sliced.nodes(data=True):
        if not attrs.get("slice_reasons"):
            failures.append(f"{node} has no recorded reason")
    for job_node in jobs:
        if job_node == target:
            continue
        role = sliced.nodes[job_node].get("slice_role")
        edge_types = JUSTIFYING_EDGES.get(role, REACH_EDGES)
        reach = reach_graph(edge_types)
        best = None
        for start in [job_node] + [s for s in steps if sliced.nodes[s]["job"] == job_node]:
            if start in reach and nx.has_path(reach, start, sink):
                path = nx.shortest_path(reach, start, sink)[:-1]
                if best is None or len(path) < len(best):
                    best = path
        if best is None:
            failures.append(f"{label[job_node]} ({role}) has no path to the target through "
                            f"{'/'.join(sorted(edge_types))} edges")
        else:
            hops = [best[0]]
            for u, v in zip(best, best[1:]):
                kinds = sorted({k for _, w, k in sliced.out_edges(u, keys=True) if w == v} & edge_types)
                hops.append(f"-{'|'.join(kinds)}-> {v}")
            paths[label[job_node]] = {"role": sliced.nodes[job_node].get("slice_role"),
                                      "reasons": sliced.nodes[job_node]["slice_reasons"],
                                      "path": " ".join(hops)}
    record("justification", failures, justified=paths)

    # ── dynamic_references ────────────────────────────────────────────────────
    contexts, warnings = Counter(), []
    # inputs a kept caller passes, possibly as a runtime value (needs.X.outputs.Y)
    bound_inputs = {a["name"] for n, a in sliced.nodes(data=True)
                    if a.get("resource_type") == "input" and any(p in sliced for p in _producers(sliced, n))}
    fields = {"jobs": ("runs_on", "env", "if", "container", "services", "with", "defaults_run"),
              "steps": ("run", "uses", "with", "env", "if", "working_directory", "shell", "expanded_steps")}
    for kind, entries in (("jobs", sl["jobs"]), ("steps", sl["steps"])):
        for entry in entries:
            if entry.get("execution") == "record_constraint_only":
                continue
            for field in fields[kind]:
                for text in _strings(entry.get(field)):
                    for expr in EXPRESSION.findall(text):
                        names = re.findall(r"[A-Za-z_][A-Za-z0-9_-]*(?=\s*[.\[])", expr)
                        context = next((n for n in names if n in CONTEXTS), "function_or_literal")
                        contexts[context] += 1
                        unbound = {i for i in re.findall(r"\binputs\.([A-Za-z0-9_-]+)", expr)
                                   if i not in bound_inputs}
                        if context == "inputs" and unbound and "input" not in unresolved_kinds:
                            warnings.append(f"{entry['job']}{'.' + str(entry['index']) if 'index' in entry else ''}"
                                            f".{field}: ${{{{ {expr.strip()[:60]} }}}} is not bound")
    record("dynamic_references", warnings=warnings, by_context=dict(sorted(contexts.items())))

    overall = max((r["status"] for r in results.values()), key=STATUS_ORDER.get)
    return {"status": overall, "checks": results}
