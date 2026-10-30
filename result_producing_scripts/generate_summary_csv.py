#!/usr/bin/env python3
"""
Generate ER/TR/FR summary CSV.

Usage:
  # LLM4Build — one model at a time
  python generate_summary_csv.py output_data/llm4build --llm4build --model gpt4o
  python generate_summary_csv.py output_data/llm4build --llm4build --model claude-haiku-4-5-20251001

  # Baselines (no model)
  python generate_summary_csv.py output_data/act_output --act
  python generate_summary_csv.py output_data/action-remaker-output --action-remaker

  # Claude Code
  python generate_summary_csv.py output_data/claude-code --claude-code
  python generate_summary_csv.py output_data/claude-code --claude-code -o summary_claude_code.csv

  # Restrict to one split (default: both)
  python generate_summary_csv.py output_data/llm4build --llm4build --model gpt4o --passed
  python generate_summary_csv.py output_data/llm4build --llm4build --model gpt4o --failed
"""
import argparse
import csv
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from count_results import count_results

LANGUAGES = ["Java", "Python", "JS", "TS", "C", "C++", "Rust", "Go"]
METRICS   = ["ER", "TR", "FR"]


def count_results_baseline(language: str, base_dir: str,
                           statuses: tuple = ("passed", "failed")) -> dict:
    """Count ER/TR/FR for baselines (no model level): lang/status/project/out/summary.json"""
    total = {"ER": 0, "TR": 0, "FR": 0, "total": 0}
    for status in statuses:
        status_dir = os.path.join(base_dir, language, status)
        if not os.path.isdir(status_dir):
            continue
        for project in os.listdir(status_dir):
            json_path = os.path.join(status_dir, project, "out", "summary.json")
            if not os.path.isfile(json_path):
                continue
            try:
                with open(json_path) as f:
                    data = json.load(f)
            except json.JSONDecodeError:
                continue
            total["total"] += 1
            for key in ("ER", "TR", "FR"):
                if data.get(key) is True:
                    total[key] += 1
    return total


def print_table(rows, header, totals):
    col_w = max(len(h) for h in header[1:]) + 2
    label_w = 20
    print(f"\n{'Language':<{label_w}}", end="")
    for h in header[1:]:
        print(f"  {h:>{col_w}}", end="")
    print()
    print("-" * (label_w + (col_w + 2) * len(header[1:])))
    for row in rows:
        print(f"{row[0]:<{label_w}}", end="")
        for v in row[1:]:
            print(f"  {v:>{col_w}}", end="")
        print()
    print("-" * (label_w + (col_w + 2) * len(header[1:])))
    print(f"{'Total':<{label_w}}", end="")
    for v in totals[1:]:
        print(f"  {v:>{col_w}}", end="")
    print()


def main():
    parser = argparse.ArgumentParser(description="Generate ER/TR/FR summary CSV")
    parser.add_argument("base_dir", help="Root output folder")
    parser.add_argument("--llm4build",      action="store_true", help="LLM4Build mode (requires --model)")
    parser.add_argument("--action-remaker", action="store_true", dest="action_remaker",
                        help="action-remaker baseline mode")
    parser.add_argument("--act",            action="store_true", help="act baseline mode")
    parser.add_argument("--claude-code",    action="store_true", dest="claude_code",
                        help="claude-code mode (lang/status/project, no model level)")
    parser.add_argument("--model", default=None,
                        help="Model name for --llm4build mode (e.g. gpt4o)")
    split = parser.add_mutually_exclusive_group()
    split.add_argument("--passed", action="store_true", help="Only count passed-build artifacts")
    split.add_argument("--failed", action="store_true", help="Only count failed-build artifacts")
    parser.add_argument("--out", "-o", default=None, help="Output CSV file (default: stdout)")
    args = parser.parse_args()

    # Status filter (default: both)
    if args.passed:
        statuses = ("passed",)
    elif args.failed:
        statuses = ("failed",)
    else:
        statuses = ("passed", "failed")

    base_dir = args.base_dir.rstrip("/")
    if not os.path.isdir(base_dir):
        print(f"Error: '{base_dir}' is not a directory.", file=sys.stderr)
        sys.exit(1)

    # Determine mode
    if args.llm4build:
        if not args.model:
            parser.error("--model is required with --llm4build")
        mode = "llm4build"
        label = args.model
    elif args.action_remaker:
        mode = "baseline"
        label = "action-remaker"
    elif args.act:
        mode = "baseline"
        label = "act"
    elif args.claude_code:
        mode = "baseline"
        label = "claude-code"
    else:
        # Auto-detect
        name = os.path.basename(base_dir).lower()
        if "llm4build" in name:
            if not args.model:
                parser.error("--model is required for llm4build output")
            mode = "llm4build"
            label = args.model
        elif "claude-code" in name or "claude_code" in name:
            mode = "baseline"
            label = "claude-code"
        else:
            mode = "baseline"
            label = name

    # Build table
    header = ["Language"] + METRICS
    rows = []
    for lang in LANGUAGES:
        if mode == "llm4build":
            counts = count_results(lang, args.model, base_dir, statuses=statuses)
        else:
            counts = count_results_baseline(lang, base_dir, statuses=statuses)
        row = [lang] + [counts[m] for m in METRICS]
        rows.append(row)

    totals = ["Total"] + [sum(row[i] for row in rows) for i in range(1, len(header))]

    # Write CSV
    out = open(args.out, "w", newline="") if args.out else sys.stdout
    writer = csv.writer(out)
    writer.writerow(header)
    writer.writerows(rows)
    writer.writerow(totals)
    if args.out:
        out.close()
        print(f"Written: {args.out}")

    # Pretty-print
    if not args.out:
        print_table(rows, header, totals)


if __name__ == "__main__":
    main()
