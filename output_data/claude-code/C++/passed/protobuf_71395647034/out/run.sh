#!/usr/bin/env bash
set -e

cd /app

# Run the Bazel tests
bazel test //pkg/... //src/... //third_party/utf8_range/... //conformance:conformance_framework_tests

# If we got here, tests ran successfully
echo "FINAL_STATUS = SUCCESS"
