"""Build the GWA evaluation set.

For each `<owner>/<repo> <job_id>` line of case_ids.txt: fetch the job from
the GitHub API, check the repository out at the job's head commit, and find
the job's workflow file and matrix the way llm4build-pipeline.py does (same
utilities, same reusable-workflow handling). Each commit gets its own
checkout, repos/<owner>__<repo>@<sha12>/<repo>; existing checkouts are reused.

Writes cases.json: one entry per job, plus the synthetic cases over
fixtures/. Run from anywhere:

    python gwa_eval/build_cases.py [--only <case-id> ...]
"""
import argparse
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, ROOT)
os.chdir(ROOT)            # the pipeline utilities expect the repository root

import yaml  # noqa: E402

from job import find_dict_by_key, generate_input_file  # noqa: E402
from utils.common.credentials import GITHUB_TOKENS  # noqa: E402
from utils.common.github_wrapper import GitHubWrapper  # noqa: E402
from utils.utils import find_correct_yaml_file, find_yaml_by_job_key  # noqa: E402

# Synthetic cases over fixtures/: features the sampled jobs may not cover.
FIXTURE_CASES = [
    {"id": "fixture_matrix_outputs_artifacts", "job_name": "test 3.12 on ubuntu-24.04",
     "note": "matrix target; job output, artifact, composite action, ordering-only lint"},
    {"id": "fixture_matrix_other_combination", "job_name": "test 3.10 on ubuntu-22.04",
     "note": "same job, another matrix combination"},
    {"id": "fixture_reusable_workflow", "job_name": "call / inner",
     "note": "target in a local reusable workflow; input passed from needs outputs"},
    {"id": "fixture_conditional_needs", "job_name": "summary",
     "note": "if: always() && needs.prepare.result == 'success'"},
    {"id": "fixture_static_conditions", "job_name": "test 3.12", "workflow": ".github/workflows/conditions.yml",
     "note": "runner.os, matrix, event and env conditions; a producer that is statically unreachable"},
]
FIXTURE_RUN = {"event": "push", "head_branch": "main", "repository": {"full_name": "fixture/basic"}}


def run_metadata(github, repo, run_id):
    """What Static Condition Resolution reads from the API run: event, branch, pull requests."""
    _, run = github.get(f"https://api.github.com/repos/{repo}/actions/runs/{run_id}")
    run = run or {}
    return {"event": run.get("event"), "head_branch": run.get("head_branch"), "name": run.get("name"),
            "repository": {"full_name": (run.get("repository") or {}).get("full_name")},
            "pull_requests": [{"number": p.get("number"), "base": {"ref": (p.get("base") or {}).get("ref")},
                               "head": {"ref": (p.get("head") or {}).get("ref")}}
                              for p in run.get("pull_requests") or []]}


def checkout(repo, sha):
    """The repository at `sha`: a depth-1 fetch of that commit, reused when present."""
    owner, name = repo.split("/")
    parent = os.path.join(HERE, "repos", f"{owner}__{name}@{sha[:12]}")
    path = os.path.join(parent, name)
    if os.path.isdir(os.path.join(path, ".git")):
        head = subprocess.run(["git", "rev-parse", "HEAD"], cwd=path, capture_output=True, text=True)
        if head.stdout.strip() == sha:
            return parent, path
    os.makedirs(path, exist_ok=True)

    def git(*args):
        subprocess.run(["git", *args], cwd=path, check=True, capture_output=True, timeout=1800)

    git("init", "-q")
    subprocess.run(["git", "remote", "add", "origin", f"https://github.com/{repo}.git"], cwd=path,
                   capture_output=True)
    git("fetch", "-q", "--depth", "1", "origin", sha)
    git("checkout", "-q", "--force", "FETCH_HEAD")
    return parent, path


def find_workflow(parent, name, job):
    """The workflow file, as llm4build-pipeline.py finds it."""
    job_name = job.get("workflow_name") or job.get("name", "")
    specific = job["name"]
    workflow = (find_correct_yaml_file(parent, name, job_name)
                or find_correct_yaml_file(parent, name, specific)
                or find_yaml_by_job_key(parent, name, specific))
    if workflow and " / " in specific:
        # a reusable workflow called from this file: the pipeline switches to it
        try:
            with open(workflow) as f:
                data = yaml.safe_load(f)
            entry = (data.get("jobs") or {}).get(specific.split(" / ")[0].strip(), {})
            uses = entry.get("uses", "") if isinstance(entry, dict) else ""
            if uses.startswith("./.github/") and os.path.isfile(os.path.join(parent, name, uses[2:])):
                workflow = os.path.join(parent, name, uses[2:])
        except Exception:  # noqa: BLE001 -- keep the caller file, as the pipeline does
            pass
    return workflow


def build_case(github, repo, job_id):
    name = repo.split("/")[1]
    case = {"id": f"{name}_{job_id}", "repo": repo, "job_id": int(job_id)}
    status, job = github.get(f"https://api.github.com/repos/{repo}/actions/jobs/{job_id}")
    if not job:
        return {**case, "error": "job not found in the GitHub API"}
    case.update(job_name=job["name"], job_url=job.get("html_url"), run_id=job.get("run_id"),
                labels=job.get("labels") or [], head_sha=job["head_sha"],
                run=run_metadata(github, repo, job.get("run_id")))
    parent, path = checkout(repo, job["head_sha"])
    workflow = find_workflow(parent, name, job)
    if workflow is None:
        return {**case, "error": "no workflow file matches the job"}
    config = generate_input_file(repo, job_id, None)
    matrix = (find_dict_by_key(config["passed_build"]["jobs"][0]["config"], "matrix")
              or find_dict_by_key(config["failed_build"]["jobs"][0]["config"], "matrix") or {})
    case.update(checkout=os.path.relpath(path, HERE), workflow=os.path.relpath(workflow, path),
                matrix=matrix)
    return case


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--only", nargs="*", help="case ids to (re)build; others are kept")
    args = parser.parse_args()

    cases_path = os.path.join(HERE, "cases.json")
    existing = {}
    if os.path.exists(cases_path):
        existing = {c["id"]: c for c in json.load(open(cases_path))}

    cases = [{"id": f["id"], "kind": "fixture", "repo": None, "job_id": None, "job_name": f["job_name"],
              "note": f["note"], "checkout": "fixtures/basic",
              "workflow": f.get("workflow", ".github/workflows/ci.yml"),
              "matrix": {}, "labels": [], "run": FIXTURE_RUN} for f in FIXTURE_CASES]
    github = GitHubWrapper(GITHUB_TOKENS)
    with open(os.path.join(HERE, "case_ids.txt")) as f:
        ids = [line.split() for line in f if line.strip() and not line.startswith("#")]
    for repo, job_id in ids:
        case_id = f"{repo.split('/')[1]}_{job_id}"
        if case_id in existing and not existing[case_id].get("error") and \
                (not args.only or case_id not in args.only):
            case = existing[case_id]
            if "run" not in case:            # added for Static Condition Resolution
                case["run"] = run_metadata(github, repo, case["run_id"])
            cases.append(case)
            continue
        try:
            case = build_case(github, repo, job_id)
        except Exception as e:  # noqa: BLE001 -- one bad case must not stop the set
            case = {"id": case_id, "repo": repo, "job_id": int(job_id), "error": f"{type(e).__name__}: {e}"}
        cases.append({"kind": "dataset", **case})
        print(json.dumps({k: case.get(k) for k in ("id", "job_name", "workflow", "error")}), flush=True)
        with open(cases_path, "w") as f:          # progress survives an interruption
            json.dump(cases + [c for c in existing.values() if c["id"] not in {x["id"] for x in cases}],
                      f, indent=1)
    with open(cases_path, "w") as f:
        json.dump(cases, f, indent=1)
    print(f"{len(cases)} cases, {sum(1 for c in cases if c.get('error'))} with errors -> {cases_path}")


if __name__ == "__main__":
    main()
