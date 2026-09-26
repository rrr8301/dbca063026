import os
import json
import argparse
import csv
import sys

from installation_file_list import has_tests_run


def read_log_lines(log_path):
    if not os.path.isfile(log_path):
        return []
    with open(log_path, "r", errors="replace") as f:
        return f.readlines()


def extract_failed_names(tests_failed):
    """Flatten tests_failed (list of dicts with 'file'/'failures') to a set of names."""
    names = set()
    for entry in (tests_failed or []):
        if isinstance(entry, dict):
            names.add(entry.get("file", ""))
            for f in entry.get("failures", []):
                names.add(f.get("name", ""))
        elif isinstance(entry, str):
            names.add(entry)
    names.discard("")
    return names


def compute_fr(llm, orig, build_status):
    llm_run    = llm.get("num_tests_run",    0)
    llm_failed = llm.get("num_tests_failed", 0)
    orig_run   = orig.get("num_tests_run",   0)
    orig_failed= orig.get("num_tests_failed",0)

    if build_status == "passed":
        return llm_run > 0 and llm_failed == 0 and llm_run == orig_run

    # failed build: hierarchical match
    if llm_run != orig_run:
        return False
    if llm_failed != orig_failed:
        return False
    llm_names  = extract_failed_names(llm.get("tests_failed",  []))
    orig_names = extract_failed_names(orig.get("tests_failed", []))
    return llm_names == orig_names


def has_original_log(project_dir):
    out_dir = os.path.join(project_dir, "out")
    if not os.path.isdir(out_dir):
        return False
    for f in os.listdir(out_dir):
        if f.endswith(".log") and f != "log.txt":
            return True
    return False


def process_project(project_dir, build_status):
    json_new_path = os.path.join(project_dir, "out", "summary.json")
    out_json_path = os.path.join(project_dir, "out", "out.json")
    log_path = os.path.join(project_dir, "out", "log.txt")

    # Use pre-computed values from summary.json if available
    if os.path.isfile(json_new_path):
        try:
            with open(json_new_path) as f:
                data = json.load(f)
            er = bool(data.get("ER"))
            tr = bool(data.get("TR"))
            fr = bool(data.get("FR")) and tr
            return er, tr, fr
        except Exception as e:
            print(f"  [ERROR] {json_new_path}: {e}", file=sys.stderr)

    # Fallback: compute from out.json + log.txt
    er = os.path.isfile(out_json_path)

    log_lines = read_log_lines(log_path)
    tr = has_tests_run(log_lines) if log_lines else False

    fr = False
    if er:
        try:
            with open(out_json_path) as f:
                data = json.load(f)
            if data:
                llm  = data[0]
                orig = (llm.get("original_log_results") or [{}])[0]
                fr   = compute_fr(llm, orig, build_status)
        except Exception as e:
            print(f"  [ERROR] {out_json_path}: {e}", file=sys.stderr)

    return er, tr, fr


def yn(flag):
    return "Y" if flag else "N"


def print_results(folder, results):
    W = 72
    FMT = "  {:<45}  {:^4}  {:^4}  {:^4}"
    print(f"\nFolder: {folder}")
    print("=" * W)
    print(FMT.format("Repo", "ER", "TR", "FR"))
    print("  " + "-" * (W - 2))
    for project, er, tr, fr in results:
        print(FMT.format(project[:45], yn(er), yn(tr), yn(fr)))
    print("  " + "-" * (W - 2))

    total = len(results)
    er_count = sum(1 for _, er, _, _ in results if er)
    tr_count = sum(1 for _, _, tr, _ in results if tr)
    fr_count = sum(1 for _, _, _, fr in results if fr)
    print(f"\n  Total : {total}")
    print(f"  ER : {er_count}/{total}  ({100*er_count/total:.1f}%)" if total else "")
    print(f"  TR : {tr_count}/{total}  ({100*tr_count/total:.1f}%)" if total else "")
    print(f"  FR : {fr_count}/{total}  ({100*fr_count/total:.1f}%)" if total else "")
    print()


FIELDS = ["project", "ER", "TR", "FR"]


def main():
    p = argparse.ArgumentParser(description="ER/TR/FR comparison for a folder")
    p.add_argument("folder", help="e.g. output_data/JS/passed/gpt4o  or a single project dir with --single")
    p.add_argument("--single", action="store_true", help="Treat folder as a single project directory")
    p.add_argument("--csv", default="", help="Optional CSV output path")
    args = p.parse_args()

    folder = args.folder.rstrip("/")
    if not os.path.isdir(folder):
        print(f"Error: '{folder}' is not a directory.", file=sys.stderr)
        sys.exit(1)

    # Detect build status from folder path (e.g. .../passed/... or .../failed/...)
    parts = folder.replace("\\", "/").split("/")
    build_status = "passed" if "passed" in parts else "failed"

    results = []
    if args.single:
        if not has_original_log(folder):
            print(f"  [SKIP] {os.path.basename(folder)}: no original log file")
        else:
            er, tr, fr = process_project(folder, build_status)
            results.append((os.path.basename(folder), er, tr, fr))
    else:
        for project in sorted(os.listdir(folder)):
            project_dir = os.path.join(folder, project)
            if not os.path.isdir(project_dir):
                continue
            if not has_original_log(project_dir):
                print(f"  [SKIP] {project}: no original log file")
                continue
            er, tr, fr = process_project(project_dir, build_status)
            results.append((project, er, tr, fr))

    print_results(folder, results)

    if args.csv:
        with open(args.csv, "w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=FIELDS)
            writer.writeheader()
            for project, er, tr, fr in results:
                writer.writerow({"project": project, "ER": yn(er), "TR": yn(tr), "FR": yn(fr)})
        print(f"CSV written to: {args.csv}")


if __name__ == "__main__":
    main()
