#!/bin/bash

# Ensure all tests are executed
set +e

# Run tests using the exact command from the YAML
./scripts/run_bazel.py \
  --attempts=5 --jobs-on-last-attempt=4 \
  test \
  --target_pattern_file=$TARGETS_FILE

# Remove unsupported Bazel options from .bazelrc
sed -i '/--incompatible_java_common_parameters/d' /app/.bazelrc