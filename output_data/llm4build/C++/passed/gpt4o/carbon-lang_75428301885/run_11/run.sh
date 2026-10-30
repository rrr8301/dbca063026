#!/bin/bash

# Ensure all tests are executed
set +e

# Check if .bazelrc exists before attempting to modify it
if [ -f /app/.bazelrc ]; then
  # Remove unsupported Bazel options from .bazelrc before running tests
  sed -i '/--incompatible_java_common_parameters/d' /app/.bazelrc
  sed -i '/--incompatible_merge_fixed_and_default_shell_env/d' /app/.bazelrc
fi

# Debugging: Print the contents of the TARGETS_FILE
echo "Contents of TARGETS_FILE:"
cat $TARGETS_FILE

# Ensure the TARGETS_FILE is not empty
if [ ! -s $TARGETS_FILE ]; then
  echo "ERROR: TARGETS_FILE is empty or not found."
  exit 1
fi

# Run tests using the exact command from the YAML
./scripts/run_bazel.py \
  --attempts=5 --jobs-on-last-attempt=4 \
  test \
  --target_pattern_file=$TARGETS_FILE

# Check the exit status of the Bazel test command
if [ $? -ne 0 ]; then
  echo "ERROR: Bazel tests failed."
  exit 1
fi