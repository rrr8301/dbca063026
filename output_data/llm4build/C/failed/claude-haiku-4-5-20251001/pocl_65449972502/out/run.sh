#!/bin/bash
set -e

cd /workspace/build
/workspace/tools/scripts/run_cpu_tests -j$(nproc) $CTEST_FLAGS "$@"