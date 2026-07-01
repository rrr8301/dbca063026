#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Update Python requirements via Bazel
echo "=== Updating requirements ==="
bazel run //fleetbench:requirements.update

# Build the project
echo "=== Building project ==="
bazel build -c fastbuild //...

# Run tests
echo "=== Running tests ==="
bazel test -c fastbuild --test_output=errors //...

echo "=== All tests completed successfully ==="