"""Freeze the current GWA as a named baseline.

Copies gwa.py and gwa_validation.py into frozen/<name>/, records their hashes
and the repository commit, extracts the graph schema the 74 evaluation cases
exercise (node types and attributes, resource types, edge types and their
dependency classes), and keeps the validation results and per-case
fingerprints, so later versions can be compared against exactly this one.

    python gwa_eval/freeze_gwa.py <name>      # e.g. gwa_v1
"""
import datetime
import hashlib
import json
import os
import shutil
import subprocess
import sys
from collections import Counter, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
SOURCES = ("gwa.py", "gwa_validation.py")


def sha256(path):
    with open(path, "rb") as f:
        return hashlib.sha256(f.read()).hexdigest()


def graph_schema(frozen_dir, cases):
    """Node and edge vocabulary over every case's full graph."""
    sys.path[:0] = [frozen_dir, ROOT]          # the frozen copy first; utils/ from the repository
    from gwa import GraphWorkflowAnalyzer

    nodes = defaultdict(Counter)
    resources = defaultdict(Counter)
    edges = defaultdict(Counter)
    for case in cases:
        path = os.path.join(HERE, case["checkout"])
        analyzer = GraphWorkflowAnalyzer(path, os.path.join(path, case["workflow"]),
                                         {"id": case["job_id"], "name": case["job_name"]}, case["matrix"])
        analyzer.analyze()
        for _, attrs in analyzer.graph.nodes(data=True):
            kind = attrs.get("type", "?")
            nodes[kind]["__count__"] += 1
            nodes[kind].update(attrs.keys())
            if kind == "resource":
                resources[attrs["resource_type"]]["__count__"] += 1
                resources[attrs["resource_type"]].update(attrs.keys())
        for _, _, attrs in analyzer.graph.edges(data=True):
            edges[attrs["type"]][attrs["dependency"]] += 1

    def table(counter_map):
        return {kind: {"count": c.pop("__count__"), "attributes": sorted(c)}
                for kind, c in sorted(counter_map.items())}

    return {"node_types": table(nodes), "resource_types": table(resources),
            "edge_types": {kind: dict(sorted(c.items())) for kind, c in sorted(edges.items())}}


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    name = sys.argv[1]
    target = os.path.join(HERE, "frozen", name)
    if os.path.exists(target):
        sys.exit(f"{target} exists; a frozen baseline is never overwritten")
    os.makedirs(target)
    for source in SOURCES:
        shutil.copy2(os.path.join(ROOT, source), target)
    report = os.path.join(HERE, "report")
    os.makedirs(os.path.join(target, "report"))
    for item in ("summary.md", "validation.json", "validation.csv"):
        shutil.copy2(os.path.join(report, item), os.path.join(target, "report"))

    cases = [c for c in json.load(open(os.path.join(HERE, "cases.json"))) if not c.get("error")]
    records = json.load(open(os.path.join(report, "validation.json")))
    commit = subprocess.run(["git", "rev-parse", "HEAD"], cwd=ROOT, capture_output=True, text=True).stdout.strip()
    manifest = {
        "name": name,
        "frozen_at": datetime.datetime.now().isoformat(timespec="seconds"),
        "repository_commit": commit,
        "note": "gwa.py / gwa_validation.py were uncommitted when frozen; these copies are the reference",
        "files": {s: sha256(os.path.join(target, s)) for s in SOURCES},
        "cases": len(cases),
        "fingerprints": {r["id"]: r["fingerprints"] for r in records if "fingerprints" in r},
    }
    with open(os.path.join(target, "MANIFEST.json"), "w") as f:
        json.dump(manifest, f, indent=1)
    with open(os.path.join(target, "schema.json"), "w") as f:
        json.dump(graph_schema(target, cases), f, indent=1)
    print(f"frozen {name}: {', '.join(SOURCES)}, schema, {len(manifest['fingerprints'])} fingerprints -> {target}")


if __name__ == "__main__":
    main()
