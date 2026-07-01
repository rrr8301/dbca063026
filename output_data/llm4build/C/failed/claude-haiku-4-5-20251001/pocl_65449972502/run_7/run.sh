#!/bin/bash
set -e

/workspace/tools/scripts/run_cpu_tests -j$(nproc) $CTEST_FLAGS "$@"