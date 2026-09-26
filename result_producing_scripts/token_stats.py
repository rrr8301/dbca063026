#!/usr/bin/env python3
"""
Calculate per-language, per-model token statistics from llm4build output directories.
Uses out/tokens.json (cumulative_total_tokens) for each repo run.
"""

import json
import os
import statistics
import argparse
from collections import defaultdict


def collect_tokens(base_dirs):
    # { (lang, model): [tokens, ...] }
    data = defaultdict(list)

    for base_dir in base_dirs:
        if not os.path.isdir(base_dir):
            continue
        for lang in os.listdir(base_dir):
            lang_path = os.path.join(base_dir, lang)
            if not os.path.isdir(lang_path):
                continue
            for status in os.listdir(lang_path):
                status_path = os.path.join(lang_path, status)
                if not os.path.isdir(status_path):
                    continue
                for model in os.listdir(status_path):
                    model_path = os.path.join(status_path, model)
                    if not os.path.isdir(model_path):
                        continue
                    for repo in os.listdir(model_path):
                        token_file = os.path.join(model_path, repo, "out", "tokens.json")
                        if not os.path.isfile(token_file):
                            continue
                        try:
                            with open(token_file) as f:
                                d = json.load(f)
                            tokens = d.get("cumulative_total_tokens") or d.get("total_tokens")
                            if tokens is not None:
                                data[(lang, model)].append(int(tokens))
                        except Exception:
                            continue

    return data


def print_stats(data):
    langs = sorted(set(lang for lang, _ in data))
    models = sorted(set(model for _, model in data))

    col_w = 12
    header = f"{'Lang':<10} {'Model':<35} {'Count':>6} {'Min':>10} {'Max':>10} {'Mean':>10} {'Median':>10} {'Total':>14}"
    sep = "-" * len(header)
    print(header)
    print(sep)

    all_tokens = []
    for lang in langs:
        for model in models:
            tokens = data.get((lang, model))
            if not tokens:
                continue
            all_tokens.extend(tokens)
            print(
                f"{lang:<10} {model:<35} {len(tokens):>6} {min(tokens):>10,} {max(tokens):>10,} "
                f"{statistics.mean(tokens):>10,.0f} {statistics.median(tokens):>10,.0f} "
                f"{sum(tokens):>14,}"
            )
        # Per-lang total across all models
        lang_tokens = [t for (l, _), ts in data.items() if l == lang for t in ts]
        print(
            f"{'':10} {'  >> ' + lang + ' total':<35} {len(lang_tokens):>6} {min(lang_tokens):>10,} "
            f"{max(lang_tokens):>10,} {statistics.mean(lang_tokens):>10,.0f} "
            f"{statistics.median(lang_tokens):>10,.0f} {sum(lang_tokens):>14,}"
        )
        print(sep)

    if all_tokens:
        print(
            f"{'TOTAL':<10} {'all models':<35} {len(all_tokens):>6} {min(all_tokens):>10,} {max(all_tokens):>10,} "
            f"{statistics.mean(all_tokens):>10,.0f} {statistics.median(all_tokens):>10,.0f} "
            f"{sum(all_tokens):>14,}"
        )


def main():
    parser = argparse.ArgumentParser(description="Token statistics per language and model")
    parser.add_argument(
        "dirs",
        nargs="*",
        default=[
            "/scratch/raian-files/LLM4Build/output_data/llm4build",
            "/scratch/raian-files/LLM4Build/dummy_output/llm4build",
        ],
        help="Base llm4build output directories to scan",
    )
    parser.add_argument(
        "--output", "-o",
        default=None,
        help="Output file path to save results (default: print to stdout)",
    )
    args = parser.parse_args()

    data = collect_tokens(args.dirs)
    if not data:
        print("No token data found.")
        return

    if args.output:
        import sys
        orig_stdout = sys.stdout
        with open(args.output, "w") as f:
            sys.stdout = f
            print_stats(data)
        sys.stdout = orig_stdout
        print(f"Results saved to {args.output}")
    else:
        print_stats(data)


if __name__ == "__main__":
    main()
