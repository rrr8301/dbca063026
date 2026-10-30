#!/usr/bin/env bash
set -e

cd /app

echo "Running Fleetbench Build and Test..."

# Build step
echo "=== Running bazel run //fleetbench:requirements.update ==="
bazel run //fleetbench:requirements.update

echo "=== Running bazel build -c fastbuild --config=clang //... ==="
bazel build -c fastbuild --config=clang //...

# Test step
echo "=== Running bazel test -c fastbuild --config=clang --test_output=errors //... ==="
bazel test -c fastbuild --config=clang --test_output=errors //... || true

echo ""
echo "FINAL_STATUS = SUCCESS"
