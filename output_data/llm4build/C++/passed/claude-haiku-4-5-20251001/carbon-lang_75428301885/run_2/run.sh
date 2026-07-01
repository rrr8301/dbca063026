#!/bin/bash
set -e

./scripts/run_bazel.py \
  --attempts=5 --jobs-on-last-attempt=4 \
  test \
  --target_pattern_file=$TARGETS_FILE