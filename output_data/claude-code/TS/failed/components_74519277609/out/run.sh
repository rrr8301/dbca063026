#!/usr/bin/env bash
set -e

cd /app

echo "Running Bazel tests..."
bazel test --build_tests_only --test_tag_filters=-linker-integration-test --test_tag_filters=-e2e -- //... -//goldens/... -//integration/...

TEST_EXIT_CODE=$?

if [ $TEST_EXIT_CODE -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = FAIL"
fi

exit $TEST_EXIT_CODE
