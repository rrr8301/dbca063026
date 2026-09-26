#!/usr/bin/env bash
set -e

cd /app/build

rm -rf "${POCL_CACHE_DIR}"
mkdir -p "${POCL_CACHE_DIR}"

CTEST_FLAGS="--output-on-failure --test-output-size-failed 192000 --test-output-size-passed 192000"

echo "Running tests with run_cpu_tests script..."
/app/tools/scripts/run_cpu_tests -j$(nproc) $CTEST_FLAGS "$@" || TEST_FAILED=1

if [ "$TEST_FAILED" = "1" ]; then
    echo "FINAL_STATUS = FAIL"
    exit 1
else
    echo "FINAL_STATUS = SUCCESS"
fi
