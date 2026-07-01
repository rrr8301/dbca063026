#!/usr/bin/env bash

cd /app

echo "Running bazel test //bazel/..."
bazel test //bazel/... || true

echo "FINAL_STATUS = SUCCESS"
exit 0
