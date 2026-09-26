#!/usr/bin/env python3
"""
Run extract_stats.py for every directory in a base folder.

Auto-detects structure from the last path component, or use explicit flags:
  --llm4build   {MAINDIR}/llm4build/{lang}/{pass_fail}/{model}/{repo}_{job_id}
  --remaker     {MAINDIR}/action-remaker/{lang}/{pass_fail}/{repo}_{job_id}
  --act         {MAINDIR}/act_output/{lang}/{pass_fail}/{repo}_{job_id}
  --claude-code {MAINDIR}/claude-code/{lang}/{pass_fail}/{repo}_{job_id}

Examples:
  python run_extract_all.py output_data/llm4build
  python run_extract_all.py output_data/action-remaker-output
  python run_extract_all.py output_data/act_output
  python run_extract_all.py output_data/claude-code --claude-code
  python run_extract_all.py output_data/llm4build --llm4build -o results.txt
"""
import os
import sys
import argparse
import subprocess

SCRIPT_DIR  = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)  # LLM4Build root


def detect_mode(base_dir):
    """Auto-detect mode from folder name."""
    name = os.path.basename(base_dir.rstrip("/")).lower()
    if "llm4build" in name:
        return "llm4build"
    if "claude-code" in name or "claude_code" in name:
        return "claude-code"
    if "act" in name and "remaker" not in name:
        return "act"
    return "action-remaker"


def main():
    p = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("base_dir", help="Root output folder (llm4build, action-remaker, or act_output)")
    p.add_argument("--mode", choices=["llm4build", "action-remaker"], default=None,
                   help="Override auto-detected mode")
    p.add_argument("--llm4build", action="store_true",
                   help="Force llm4build mode: lang/status/model/project")
    p.add_argument("--action-remaker", action="store_true", dest="action_remaker",
                   help="Force action-remaker/act mode: lang/status/project")
    p.add_argument("--act", action="store_true",
                   help="Alias for --action-remaker")
    p.add_argument("--claude-code", action="store_true", dest="claude_code",
                   help="Force claude-code mode: lang/status/project (ER=False if log.txt absent)")
    p.add_argument("--lang", default=None,
                   help="Filter to a specific language (e.g. Java, Python, Rust)")
    p.add_argument("--status", choices=["passed", "failed"], default=None,
                   help="Filter to passed or failed only")
    p.add_argument("--model", default=None,
                   help="Filter to a specific model (llm4build mode only, e.g. gpt4o)")
    p.add_argument("--all", action="store_true", dest="all_modes",
                   help="Process llm4build, action-remaker, and act subfolders under base_dir")
    p.add_argument("--output", "-o", default=None, help="Save combined output to a file")
    args = p.parse_args()

    base_dir = args.base_dir.rstrip("/")
    if not os.path.isdir(base_dir):
        print(f"Error: '{base_dir}' is not a directory.", file=sys.stderr)
        sys.exit(1)

    # --all: navigate to the tool's subfolder under base_dir
    if args.all_modes:
        tool_subdirs = {
            "llm4build":      "llm4build",
            "action-remaker": "action-remaker",
            "act":            "act",
        }
        # Determine which tool was specified
        if args.llm4build:
            tool = "llm4build"
        elif args.action_remaker:
            tool = "action-remaker"
        elif args.act:
            tool = "act"
        else:
            print("Error: --all requires a tool flag (--llm4build, --action-remaker, or --act)", file=sys.stderr)
            sys.exit(1)
        subdir = os.path.join(base_dir, tool_subdirs[tool])
        if not os.path.isdir(subdir):
            print(f"Error: '{subdir}' not found.", file=sys.stderr)
            sys.exit(1)
        base_dir = subdir

    # Resolve mode: explicit flag > --mode > auto-detect
    if args.llm4build:
        mode = "llm4build"
    elif args.action_remaker:
        mode = "action-remaker"
    elif args.act:
        mode = "act"
    elif args.claude_code:
        mode = "claude-code"
    elif args.mode:
        mode = args.mode
    else:
        mode = detect_mode(base_dir)

    print(f"Mode: {mode}  |  Dir: {base_dir}")

    if mode == "action-remaker":
        extra_flags = ["--remaker"]
    elif mode == "act":
        extra_flags = ["--act"]
    elif mode == "claude-code":
        extra_flags = ["--claude-code"]
    else:
        extra_flags = []

    out_file = open(args.output, "w") if args.output else None

    def run_extract(target_dir, flags, label):
        print(f"\n{'='*60}")
        print(f"  {label}")
        print(f"{'='*60}")
        result = subprocess.run(
            [sys.executable, os.path.join(SCRIPT_DIR, "extract_stats.py"), target_dir] + flags,
            capture_output=(out_file is not None),
            cwd=PROJECT_DIR,
        )
        if out_file is not None and result.stdout:
            out_file.write(result.stdout.decode(errors="replace"))
        if result.returncode != 0:
            print(f"  [ERROR] exit code {result.returncode}", file=sys.stderr)

    statuses = [args.status] if args.status else ("passed", "failed")

    # Detect if base_dir is already at lang level (contains passed/failed directly)
    subdirs = set(os.listdir(base_dir))
    at_lang_level = "passed" in subdirs or "failed" in subdirs

    if at_lang_level:
        langs    = [os.path.basename(base_dir)]
        lang_dir_map = {os.path.basename(base_dir): base_dir}
    else:
        langs = [args.lang] if args.lang else sorted(os.listdir(base_dir))
        lang_dir_map = {lang: os.path.join(base_dir, lang) for lang in langs}

    for lang in langs:
        lang_dir = lang_dir_map[lang]
        if not os.path.isdir(lang_dir):
            continue

        for status in statuses:
            status_dir = os.path.join(lang_dir, status)
            if not os.path.isdir(status_dir):
                continue

            if mode == "llm4build":
                # lang/status/model/project — iterate models
                models = [args.model] if hasattr(args, 'model') and args.model else sorted(os.listdir(status_dir))
                for model in models:
                    model_dir = os.path.join(status_dir, model)
                    if not os.path.isdir(model_dir):
                        continue
                    run_extract(model_dir, extra_flags, f"{lang} / {status} / {model}")
            else:
                # lang/status/project — action-remaker, act, and claude-code
                run_extract(status_dir, extra_flags, f"{lang} / {status}")


    if out_file:
        out_file.close()
        print(f"\nOutput saved to: {args.output}")

    print(f"\nAll done.")


if __name__ == "__main__":
    main()
