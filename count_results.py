#!/usr/bin/env python3
import argparse
import json
import os
import sys


def count_results(language: str, model: str, base_dir: str = None,
                  statuses: tuple = ("passed", "failed")) -> dict:
    if base_dir is None:
        base_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "output_data")

    total = {"ER": 0, "TR": 0, "FR": 0, "total": 0}

    for status in statuses:
        model_dir = os.path.join(base_dir, language, status, model)
        if not os.path.isdir(model_dir):
            continue
        for project in os.listdir(model_dir):
            json_path = os.path.join(model_dir, project, "out", "summary.json")
            if not os.path.isfile(json_path):
                continue
            with open(json_path) as f:
                try:
                    data = json.load(f)
                except json.JSONDecodeError:
                    print(f"Warning: could not parse {json_path}", file=sys.stderr)
                    continue
            total["total"] += 1
            for key in ("ER", "TR", "FR"):
                if data.get(key) is True:
                    total[key] += 1

    return total


def main():
    parser = argparse.ArgumentParser(description="Count ER/TR/FR results by language and model")
    parser.add_argument("language", help="Language (e.g. Rust, Python, Go)")
    parser.add_argument("model", help="Model name (e.g. gpt4o, claude-haiku-4-5-20251001)")
    parser.add_argument("--base-dir", default=None, help="Path to output_data directory (default: ./output_data)")
    args = parser.parse_args()

    counts = count_results(args.language, args.model, args.base_dir)

    if counts["total"] == 0:
        print(f"No summary.json files found for language='{args.language}' model='{args.model}'")
        sys.exit(1)

    print(f"Language : {args.language}")
    print(f"Model : {args.model}")
    print(f"Total : {counts['total']}")
    print(f"Total ER : {counts['ER']}")
    print(f"Total TR : {counts['TR']}")
    print(f"Total FR : {counts['FR']}")


if __name__ == "__main__":
    main()
