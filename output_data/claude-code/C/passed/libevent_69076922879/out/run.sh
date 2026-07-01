#!/usr/bin/env bash

set -e

JOBS=20
export CTEST_PARALLEL_LEVEL=$JOBS
export CTEST_OUTPUT_ON_FAILURE=1

# Enable allocator_may_return_null for test_event_calloc_enomem
export TSAN_OPTIONS=suppressions=$PWD/extra/tsan.supp:allocator_may_return_null=1
export LSAN_OPTIONS=suppressions=$PWD/extra/lsan.supp
export ASAN_OPTIONS=allocator_may_return_null=1

cd build
cmake --build . --target verify

echo "FINAL_STATUS = SUCCESS"
