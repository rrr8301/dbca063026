#!/bin/bash

# Ensure all tests are executed
set +e

# Check if .bazelrc exists before attempting to modify it
if [ -f /app/.bazelrc ]; then
  # Remove unsupported Bazel options from .bazelrc before running tests
  sed -i '/--incompatible_java_common_parameters/d' /app/.bazelrc
  sed -i '/--incompatible_merge_fixed_and_default_shell_env/d' /app/.bazelrc
fi

# Run tests using the exact command from the YAML
./scripts/run_bazel.py \
  --attempts=5 --jobs-on-last-attempt=4 \
  test \
  --target_pattern_file=$TARGETS_FILE