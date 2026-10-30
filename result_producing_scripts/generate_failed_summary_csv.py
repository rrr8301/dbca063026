#!/usr/bin/env python3
"""
Generate Existence/Number/Name/FR summary CSV for failed builds.

Usage:
  python generate_failed_summary_csv.py output_data/llm4build --llm4build --model gpt4o
  python generate_failed_summary_csv.py output_data/action-remaker --action-remaker
  python generate_failed_summary_csv.py output_data/act --act
  python generate_failed_summary_csv.py output_data/claude-code --claude-code
"""
import argparse
import csv
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

LANGUAGES = ["Java", "Python", "JS", "TS", "C", "C++", "Rust", "Go"]
METRICS   = ["Existence", "Number", "Name", "FR"]


def count_failed_llm4build(language: str, model: str, base_dir: str) -> dict:
    """lang/failed/model/project structure."""
    counts = {m: 0 for m in METRICS}
    counts["total"] = 0
    model_dir = os.path.join(base_dir, language, "failed", model)
    if not os.path.isdir(model_dir):
        return counts
    for project in os.listdir(model_dir):
        json_path = os.path.join(model_dir, project, "out", "summary.json")
        if not os.path.isfile(json_path):
            continue
        try:
            with open(json_path) as f:
                data = json.load(f)
        except json.JSONDecodeError:
            continue
        counts["total"] += 1
        for key in METRICS:
            if data.get(key) is True:
                counts[key] += 1
    return counts


def count_failed_baseline(language: str, base_dir: str) -> dict:
    """lang/failed/project structure (action-remaker, act)."""
    counts = {m: 0 for m in METRICS}
    counts["total"] = 0
    status_dir = os.path.join(base_dir, language, "failed")
    if not os.path.isdir(status_dir):
        return counts
    for project in os.listdir(status_dir):
        json_path = os.path.join(status_dir, project, "out", "summary.json")
        if not os.path.isfile(json_path):
            continue
        try:
            with open(json_path) as f:
                data = json.load(f)
        except json.JSONDecodeError:
            continue
        counts["total"] += 1
        for key in METRICS:
            if data.get(key) is True:
                counts[key] += 1
    return counts


def print_table(rows, header, totals):
    col_w = 10
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
    parser = argparse.ArgumentParser(description="Generate Existence/Number/Name/FR CSV for failed builds")
    parser.add_argument("base_dir", nargs="?", default=None,
                        help="Root output folder (e.g. output_data/llm4build)")
    parser.add_argument("--base-dir", default=None, dest="base_dir_flag")
    parser.add_argument("--llm4build",      action="store_true", help="LLM4Build mode (requires --model)")
    parser.add_argument("--action-remaker", action="store_true", dest="action_remaker",
                        help="action-remaker baseline mode")
    parser.add_argument("--act",            action="store_true", help="act baseline mode")
    parser.add_argument("--claude-code",    action="store_true", dest="claude_code",
                        help="claude-code mode (lang/failed/project, no model level)")
    parser.add_argument("--model", default=None, help="Model name (required for --llm4build)")
    parser.add_argument("--out", "-o", default=None, help="Output CSV file (default: stdout)")
    args = parser.parse_args()

    base_dir = args.base_dir or args.base_dir_flag
    if not base_dir or not os.path.isdir(base_dir):
        print(f"Error: valid base_dir required.", file=sys.stderr)
        sys.exit(1)

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

    header = ["Language"] + METRICS

    rows = []
    for lang in LANGUAGES:
        if mode == "llm4build":
            counts = count_failed_llm4build(lang, args.model, base_dir)
        else:
            counts = count_failed_baseline(lang, base_dir)
        row = [lang] + [counts[m] for m in METRICS]
        rows.append(row)

    totals = ["Total"] + [sum(row[i] for row in rows) for i in range(1, len(header))]

    out = open(args.out, "w", newline="") if args.out else sys.stdout
    writer = csv.writer(out)
    writer.writerow(header)
    writer.writerows(rows)
    writer.writerow(totals)
    if args.out:
        out.close()
        print(f"Written: {args.out}")
    else:
        print_table(rows, header, totals)


if __name__ == "__main__":
    main()
