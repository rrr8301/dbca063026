#!/usr/bin/env bash
set -e

cd /app

echo "Running requirements update..."
/usr/local/bin/bazel run //fleetbench:requirements.update || true

echo "Building with fastbuild config..."
/usr/local/bin/bazel build -c fastbuild //...

echo "Testing with fastbuild config..."
/usr/local/bin/bazel test -c fastbuild --test_output=errors //...

echo "FINAL_STATUS = SUCCESS"
