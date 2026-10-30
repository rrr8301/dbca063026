"""Validate GWA on the evaluation set and draw the manual-audit sample.

For every case in cases.json: run GWA, record its semantic validation
(gwa_validation.py), and check determinism by rerunning every case in two
subprocesses with different PYTHONHASHSEED values -- the fingerprints of the
graph, the slice and the execution slice must not change. The metric at this
stage is dependency preservation, not reproduction success.

Outputs, under report/:
  validation.json    one record per case
  validation.csv     one row per case
  summary.md         aggregate results
  audit_sample.md    stratified sample for manual audit, with what to check
  audit_sample.csv   one row per sampled case and question, for verdicts
  specs/<id>.json    the full execution specification of each case

    python gwa_eval/validate_cases.py [--semantics strict_workflow] [--per-stratum 3] [--seed 0]
"""
import argparse
import csv
import json
import os
import random
import subprocess
import sys
from collections import Counter

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, ROOT)

from gwa import GraphWorkflowAnalyzer  # noqa: E402

CHECKS = ("target_resolution", "matrix_rendering", "reusable_workflow", "conditions", "artifacts",
          "dependency_preservation", "step_ordering", "graph_spec_consistency", "justification",
          "condition_resolution", "dynamic_references")
STRATA = ("matrix", "reusable_workflow", "composite_action", "cross_job_outputs", "artifact_transfer")
HASH_SEEDS = ("1", "4242")
QUESTIONS = {
    "all": [
        "Is the target the job that ran (job name, workflow file)?",
        "Is every retained predecessor needed, for the reason given?",
        "Is any job, step, output or artifact the target needs missing from the slice?",
        "Are the unresolved dependencies really undeterminable statically?",
    ],
    "matrix": ["Is the matrix assignment the combination the job ran with (job page, log header)?"],
    "reusable_workflow": ["Is the call site right, and are the inputs it passes bound correctly?"],
    "composite_action": ["Are the composite action's steps expanded and its inputs bound correctly?"],
    "cross_job_outputs": ["Does the producer step set the output the target reads, and are the "
                          "steps kept before it enough to compute it?"],
    "artifact_transfer": ["Is the uploaded artifact the one the target downloads, and are the steps "
                          "kept before the upload enough to build it?"],
}


def analyze(case, semantics):
    path = os.path.join(HERE, case["checkout"])
    job = {"id": case["job_id"], "name": case["job_name"], "labels": case.get("labels") or [],
           "run": case.get("run")}
    return GraphWorkflowAnalyzer(path, os.path.join(path, case["workflow"]), job, case["matrix"],
                                 semantics=semantics).analyze()


def strata(spec):
    sl = spec["execution_slice"]
    target_job = next(j for j in sl["jobs"] if j["role"] == "target")
    found = []
    if target_job.get("matrix"):
        found.append("matrix")
    if spec["target"]["scope"]:
        found.append("reusable_workflow")
    if any(s["role"] == "local_action" and s.get("expanded_steps") for s in sl["steps"]):
        found.append("composite_action")
    if sl["required_outputs"]:
        found.append("cross_job_outputs")
    if sl["required_artifacts"]:
        found.append("artifact_transfer")
    return found


def record(case, spec):
    v = spec["validation"]
    sl = spec["execution_slice"]
    preservation = v["checks"]["dependency_preservation"]
    workflow_url = (f"https://github.com/{case['repo']}/blob/{case['head_sha']}/{case['workflow']}"
                    if case.get("repo") else None)
    return {
        "id": case["id"], "kind": case.get("kind"), "repo": case.get("repo"),
        "job_url": case.get("job_url"), "workflow_url": workflow_url, "workflow": case["workflow"],
        "job_name": case["job_name"], "strata": strata(spec),
        "target": spec["target"],
        "slice": [{k: j.get(k) for k in ("job", "role", "execution", "steps_kept")} for j in sl["jobs"]],
        "steps": len(sl["steps"]),
        "required_outputs": sl["required_outputs"], "required_artifacts": sl["required_artifacts"],
        "ordering_constraints": sl["ordering_constraints"],
        "unresolved": spec["unresolved_dependencies"],
        "dynamic_references": v["checks"]["dynamic_references"]["by_context"],
        "validation": v["status"],
        "checks": {name: {k: c[k] for k in ("status", "failures", "warnings") if k in c}
                   for name, c in v["checks"].items()},
        "matrix_rendered_empty": v["checks"]["matrix_rendering"]["rendered_empty"],
        "dependency_preservation": {"preserved": preservation["preserved"], "total": preservation["total"],
                                    "by_class": preservation["by_class"]},
        "justification": v["checks"]["justification"]["justified"],
        "fingerprints": spec["fingerprints"],
    }


def fingerprints_only(cases, semantics):
    """Child process: each case's fingerprints, as JSON on stdout."""
    out = {}
    for case in cases:
        try:
            out[case["id"]] = analyze(case, semantics)["fingerprints"]
        except Exception as e:  # noqa: BLE001
            out[case["id"]] = {"error": f"{type(e).__name__}: {e}"}
    print(json.dumps(out))


def determinism(cases_path, semantics):
    runs = []
    for seed in HASH_SEEDS:
        env = dict(os.environ, PYTHONHASHSEED=seed)
        result = subprocess.run([sys.executable, os.path.abspath(__file__), "--cases", cases_path,
                                 "--semantics", semantics, "--fingerprints-only"],
                                env=env, capture_output=True, text=True, check=True)
        runs.append(json.loads(result.stdout.strip().splitlines()[-1]))
    return runs


def write_summary(records, semantics, out):
    analyzed = [r for r in records if "error" not in r]
    lines = [f"# GWA validation report ({semantics})", "",
             f"Cases: {len(records)} ({sum(1 for r in records if r.get('kind') == 'fixture')} synthetic), "
             f"analyzed: {len(analyzed)}, errors: {len(records) - len(analyzed)}.", ""]
    preserved = sum(r["dependency_preservation"]["preserved"] for r in analyzed)
    total = sum(r["dependency_preservation"]["total"] for r in analyzed)
    by_class = Counter()
    for r in analyzed:
        by_class.update(r["dependency_preservation"]["by_class"])
    lines += ["## Dependency preservation", "",
              f"{preserved} / {total} mandatory dependencies of reproduced nodes are preserved "
              f"({100 * preserved / total:.1f}%)." if total else "No dependencies.", "",
              "| dependency class | edges into reproduced nodes |", "|---|---|"]
    lines += [f"| {k} | {n} |" for k, n in sorted(by_class.items())] + [""]

    lines += ["## Checks", "", "| check | pass | warn | fail |", "|---|---|---|---|"]
    for check in CHECKS:
        counts = Counter(r["checks"][check]["status"] for r in analyzed)
        lines.append(f"| {check} | {counts['pass']} | {counts['warn']} | {counts['fail']} |")
    overall = Counter(r["validation"] for r in analyzed)
    deterministic = sum(1 for r in analyzed if r.get("deterministic"))
    lines += ["", f"Overall: {overall['pass']} pass, {overall['warn']} warn, {overall['fail']} fail. "
                  f"Deterministic under PYTHONHASHSEED={'/'.join(HASH_SEEDS)}: {deterministic} / {len(analyzed)}.",
              ""]

    lines += ["## Target resolution", "", "| resolved by | cases |", "|---|---|"]
    lines += [f"| {k} | {n} |" for k, n in
              Counter(r["target"]["resolved_by"] for r in analyzed).most_common()] + [""]
    lines += ["## Strata", "", "| stratum | cases |", "|---|---|"]
    lines += [f"| {s} | {sum(1 for r in analyzed if s in r['strata'])} |" for s in STRATA] + [""]
    roles = Counter(j["role"] for r in analyzed for j in r["slice"] if j["role"] != "target")
    lines += ["## Retained predecessors", "", "| role | jobs |", "|---|---|"]
    lines += [f"| {k} | {n} |" for k, n in roles.most_common()] + [""]
    lines += ["## Unresolved dependencies", "", "| kind | occurrences |", "|---|---|"]
    lines += [f"| {k} | {n} |" for k, n in
              Counter(u["kind"] for r in analyzed for u in r["unresolved"]).most_common()] + [""]
    contexts = Counter()
    for r in analyzed:
        contexts.update(r["dynamic_references"])
    lines += ["## Dynamic references left in specifications", "", "| context | expressions |", "|---|---|"]
    lines += [f"| {k} | {n} |" for k, n in contexts.most_common()] + [""]

    lines += ["## Failures and warnings", ""]
    for r in analyzed:
        issues = [(c, s) for c, s in r["checks"].items() if s["status"] != "pass"]
        if not issues and r.get("deterministic"):
            continue
        lines.append(f"### {r['id']} — {r['validation']}")
        if not r.get("deterministic"):
            lines.append("- **not deterministic**: fingerprints differ between hash seeds")
        for check, result in issues:
            for item in result.get("failures", []):
                lines.append(f"- **{check} (fail)**: {item}")
            for item in result.get("warnings", []):
                lines.append(f"- {check} (warn): {item}")
        lines.append("")
    for r in records:
        if "error" in r:
            lines.append(f"- **error** {r['id']}: {r['error']}")
    with open(os.path.join(out, "summary.md"), "w") as f:
        f.write("\n".join(lines) + "\n")


def write_audit_sample(records, per_stratum, seed, out):
    rng = random.Random(seed)
    candidates = [r for r in records if "error" not in r and r.get("kind") == "dataset"]
    chosen, order = {}, []
    for stratum in STRATA:
        pool = sorted((r for r in candidates if stratum in r["strata"]), key=lambda r: r["id"])
        fresh = [r for r in pool if r["id"] not in chosen]
        picked = rng.sample(fresh, min(per_stratum, len(fresh)))
        if len(picked) < per_stratum:      # small stratum: reuse a case sampled for another one
            reused = [r for r in pool if r["id"] in chosen]
            picked += rng.sample(reused, min(per_stratum - len(picked), len(reused)))
        for r in sorted(picked, key=lambda r: r["id"]):
            if r["id"] not in chosen:
                order.append(r["id"])
            chosen.setdefault(r["id"], []).append(stratum)

    by_id = {r["id"]: r for r in records}
    lines = ["# GWA manual audit sample", "",
             f"Stratified by {', '.join(STRATA)}: up to {per_stratum} cases each (seed {seed}). "
             "A case sampled for one stratum counts for every stratum it belongs to. "
             "Record verdicts in audit_sample.csv.", ""]
    rows = []
    for case_id in order:
        r = by_id[case_id]
        sampled_for = chosen[case_id]
        t = r["target"]
        lines += [f"## {case_id}", "",
                  f"- **Sampled for:** {', '.join(sampled_for)} (strata: {', '.join(r['strata'])})",
                  f"- **Job:** [{r['job_name']}]({r['job_url']})",
                  f"- **Workflow at the job's commit:** [{r['workflow']}]({r['workflow_url']})",
                  f"- **Target:** `{t['yaml_job_id']}`" + (f" in `{t['scope']}`" if t["scope"] else "")
                  + f", matrix `{json.dumps(t['matrix'])}`, resolved by {t['resolved_by']}"
                  + (f"; matrix keys rendered empty (absent from the combination): "
                     f"`{', '.join(r['matrix_rendered_empty'])}`" if r["matrix_rendered_empty"] else ""),
                  f"- **Validation:** {r['validation']}; dependency preservation "
                  f"{r['dependency_preservation']['preserved']}/{r['dependency_preservation']['total']}",
                  "", "| job | role | execution | steps kept | why (path to the target) |", "|---|---|---|---|---|"]
        for j in r["slice"]:
            why = "target" if j["role"] == "target" else r["justification"].get(j["job"], {}).get("path", "")
            lines.append(f"| `{j['job']}` | {j['role']} | {j['execution']} | {j['steps_kept']} | `{why}` |")
        lines.append("")
        for title, items, fmt in (
                ("Required outputs", r["required_outputs"], lambda x: f"`{x['resource']}`: {x['producer']} → {x['consumer']}"),
                ("Required artifacts", r["required_artifacts"], lambda x: f"`{x['resource']}`: {x['producer']} → {x['consumer']}"),
                ("Ordering constraints", r["ordering_constraints"],
                 lambda x: f"{x['before']} → {x['after']} (requires_success={x['requires_success']}, "
                           f"reproduced={x['before_reproduced']})"),
                ("Unresolved", r["unresolved"], lambda x: f"{x['kind']}: {x['detail']}")):
            if items:
                lines += [f"**{title}**", ""] + [f"- {fmt(x)}" for x in items] + [""]
        lines += ["**Check**", ""]
        questions = QUESTIONS["all"] + [q for s in r["strata"] for q in QUESTIONS[s]]
        lines += [f"- [ ] {q}" for q in questions] + [""]
        rows += [{"case": case_id, "sampled_for": ";".join(sampled_for), "question": q,
                  "verdict": "", "notes": ""} for q in questions]
    with open(os.path.join(out, "audit_sample.md"), "w") as f:
        f.write("\n".join(lines) + "\n")
    with open(os.path.join(out, "audit_sample.csv"), "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["case", "sampled_for", "question", "verdict", "notes"])
        writer.writeheader()
        writer.writerows(rows)
    return order


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--cases", default=os.path.join(HERE, "cases.json"))
    parser.add_argument("--out", default=os.path.join(HERE, "report"))
    parser.add_argument("--semantics", default="target_execution",
                        choices=("target_execution", "strict_workflow"))
    parser.add_argument("--per-stratum", type=int, default=3)
    parser.add_argument("--seed", type=int, default=0)
    parser.add_argument("--fingerprints-only", action="store_true", help=argparse.SUPPRESS)
    args = parser.parse_args()

    cases = [c for c in json.load(open(args.cases)) if not c.get("error")]
    if args.fingerprints_only:
        return fingerprints_only(cases, args.semantics)

    os.makedirs(os.path.join(args.out, "specs"), exist_ok=True)
    reruns = determinism(args.cases, args.semantics)
    records = []
    for case in json.load(open(args.cases)):
        if case.get("error"):
            records.append({"id": case["id"], "kind": case.get("kind"), "error": case["error"]})
            continue
        try:
            spec = analyze(case, args.semantics)
        except Exception as e:  # noqa: BLE001 -- report it, keep going
            records.append({"id": case["id"], "kind": case.get("kind"), "error": f"{type(e).__name__}: {e}"})
            continue
        with open(os.path.join(args.out, "specs", f"{case['id']}.json"), "w") as f:
            json.dump(spec, f, indent=1, default=str)
        r = record(case, spec)
        r["deterministic"] = all(run.get(case["id"]) == spec["fingerprints"] for run in reruns)
        records.append(r)

    with open(os.path.join(args.out, "validation.json"), "w") as f:
        json.dump(records, f, indent=1, default=str)
    with open(os.path.join(args.out, "validation.csv"), "w", newline="") as f:
        fields = ["id", "kind", "validation", "deterministic", *CHECKS, "preserved", "total", "strata",
                  "resolved_by", "jobs", "steps", "unresolved", "error"]
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        for r in records:
            if "error" in r:
                writer.writerow({"id": r["id"], "kind": r.get("kind"), "error": r["error"]})
                continue
            writer.writerow({"id": r["id"], "kind": r["kind"], "validation": r["validation"],
                             "deterministic": r["deterministic"],
                             **{c: r["checks"][c]["status"] for c in CHECKS},
                             "preserved": r["dependency_preservation"]["preserved"],
                             "total": r["dependency_preservation"]["total"], "strata": ";".join(r["strata"]),
                             "resolved_by": r["target"]["resolved_by"], "jobs": len(r["slice"]),
                             "steps": r["steps"], "unresolved": len(r["unresolved"])})
    write_summary(records, args.semantics, args.out)
    sample = write_audit_sample(records, args.per_stratum, args.seed, args.out)
    analyzed = [r for r in records if "error" not in r]
    print(f"{len(analyzed)}/{len(records)} analyzed; validation "
          f"{dict(Counter(r['validation'] for r in analyzed))}; deterministic "
          f"{sum(1 for r in analyzed if r['deterministic'])}/{len(analyzed)}; audit sample {len(sample)} cases "
          f"-> {args.out}")


if __name__ == "__main__":
    main()
