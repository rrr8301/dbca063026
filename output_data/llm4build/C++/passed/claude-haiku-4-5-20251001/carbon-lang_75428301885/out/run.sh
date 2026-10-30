#!/bin/bash
set -e

# If TARGETS_FILE is not set or is empty, default to all targets
if [ -z "$TARGETS_FILE" ] || [ ! -f "$TARGETS_FILE" ] || [ ! -s "$TARGETS_FILE" ]; then
  echo "TARGETS_FILE not set or empty, using default target pattern: //..."
  TARGET_PATTERN="//..."
else
  # Verify the targets file has content
  if [ -s "$TARGETS_FILE" ]; then
    TARGET_PATTERN="--target_pattern_file=$TARGETS_FILE"
  else
    echo "TARGETS_FILE is empty, using default target pattern: //..."
    TARGET_PATTERN="//..."
  fi
fi

./scripts/run_bazel.py \
  --attempts=5 --jobs-on-last-attempt=4 \
  test \
  $TARGET_PATTERN