#!/usr/bin/env bash

set -e

cd /app

echo "Running pnpm install..."
pnpm install --frozen-lockfile

echo "Running Bazel tests..."
bazel test --build_tests_only --test_tag_filters=-linker-integration-test --test_tag_filters=-e2e -- //... -//goldens/... -//integration/...

echo "FINAL_STATUS = SUCCESS"
