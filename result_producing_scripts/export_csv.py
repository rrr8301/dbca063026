#!/usr/bin/env python3
"""
Export per-repo ER/TR/FR to CSV.

Usage:
  # LLM4Build (requires --model)
  python export_csv.py output_data/llm4build --llm4build --model gpt4o --out gpt4o.csv

  # Baselines (no model)
  python export_csv.py output_data/act_output --act --out act.csv
  python export_csv.py output_data/action-remaker-output --action-remaker --out remaker.csv
"""
import argparse
import csv
import json
import os
import re
import sys

LANGUAGES = ["Java", "Python", "JS", "TS", "C", "C++", "Rust", "Go"]


def _repo_name(dirname):
    return re.sub(r"_\d+$", "", dirname)


def _tokens(project_dir):
    path = os.path.join(project_dir, "out", "tokens.json")
    if not os.path.isfile(path):
        return ""
    with open(path) as f:
        try:
            d = json.load(f)
            return d.get("cumulative_total_tokens", d.get("total_tokens", ""))
        except Exception:
            return ""


def _comments(project_dir):
    path = os.path.join(project_dir, "out", "comments.txt")
    if not os.path.isfile(path):
        return ""
    try:
        with open(path, errors="replace") as f:
            content = f.read().strip()
        # Flatten multiline content to a single line for spreadsheet compatibility
        return " | ".join(line.strip() for line in content.splitlines() if line.strip())
    except Exception:
        return ""


def collect_llm4build(base_dir, model):
    rows = []
    for lang in LANGUAGES:
        for status in ("passed", "failed"):
            model_dir = os.path.join(base_dir, lang, status, model)
            if not os.path.isdir(model_dir):
                continue
            for project in sorted(os.listdir(model_dir)):
                project_dir = os.path.join(model_dir, project)
                if not os.path.isdir(project_dir):
                    continue
                json_path = os.path.join(project_dir, "out", "summary.json")
                if not os.path.isfile(json_path):
                    continue
                try:
                    with open(json_path) as f:
                        data = json.load(f)
                except json.JSONDecodeError:
                    continue
                result_link = (
                    f"output_data/llm4build/{lang}/{status}/{model}/{project}/out/summary.json"
                )
                rows.append({
                    "Repo": project,
                    "Language": lang,
                    "pass_or_fail": status,
                    "ER": "Y" if data.get("ER") else "N",
                    "TR": "Y" if data.get("TR") else "N",
                    "FR": "Y" if data.get("FR") else "N",
                    "attempt_number": data.get("attempt_number", ""),
                    "total_tokens": _tokens(project_dir),
                    "comments": _comments(project_dir),
                    "result_link": result_link,
                })
    return rows


def collect_baseline(base_dir):
    rows = []
    for lang in LANGUAGES:
        for status in ("passed", "failed"):
            status_dir = os.path.join(base_dir, lang, status)
            if not os.path.isdir(status_dir):
                continue
            for project in sorted(os.listdir(status_dir)):
                project_dir = os.path.join(status_dir, project)
                if not os.path.isdir(project_dir):
                    continue
                json_path = os.path.join(project_dir, "out", "summary.json")
                if not os.path.isfile(json_path):
                    continue
                try:
                    with open(json_path) as f:
                        data = json.load(f)
                except json.JSONDecodeError:
                    continue
                rows.append({
                    "Repo": project,
                    "Language": lang,
                    "pass_or_fail": status,
                    "ER": "Y" if data.get("ER") else "N",
                    "TR": "Y" if data.get("TR") else "N",
                    "FR": "Y" if data.get("FR") else "N",
                    "attempt_number": data.get("attempt_number", ""),
                    "total_tokens": "",
                    "comments": _comments(project_dir),
                    "result_link": "",
                })
    return rows


def main():
    p = argparse.ArgumentParser(description="Export per-repo ER/TR/FR to CSV")
    p.add_argument("base_dir", help="Root output folder")
    p.add_argument("--llm4build",      action="store_true", help="LLM4Build mode (requires --model)")
    p.add_argument("--action-remaker", action="store_true", dest="action_remaker",
                   help="action-remaker baseline mode")
    p.add_argument("--act",            action="store_true", help="act baseline mode")
    p.add_argument("--model", default=None, help="Model name (required for --llm4build)")
    p.add_argument("--out", "-o", default=None, help="Output CSV file (default: stdout)")
    args = p.parse_args()

    base_dir = args.base_dir.rstrip("/")
    if not os.path.isdir(base_dir):
        print(f"Error: '{base_dir}' is not a directory.", file=sys.stderr)
        sys.exit(1)

    # Determine mode
    if args.llm4build:
        if not args.model:
            p.error("--model is required with --llm4build")
        rows = collect_llm4build(base_dir, args.model)
    elif args.action_remaker or args.act:
        rows = collect_baseline(base_dir)
    else:
        # Auto-detect
        name = os.path.basename(base_dir).lower()
        if "llm4build" in name:
            if not args.model:
                p.error("--model is required for llm4build output")
            rows = collect_llm4build(base_dir, args.model)
        else:
            rows = collect_baseline(base_dir)

    fieldnames = ["Repo", "Language", "pass_or_fail", "ER", "TR", "FR", "attempt_number", "total_tokens", "comments", "result_link"]
    out = open(args.out, "w", newline="") if args.out else sys.stdout
    writer = csv.DictWriter(out, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(rows)
    if args.out:
        out.close()
        print(f"Written to {args.out}  ({len(rows)} rows)")


if __name__ == "__main__":
    main()
