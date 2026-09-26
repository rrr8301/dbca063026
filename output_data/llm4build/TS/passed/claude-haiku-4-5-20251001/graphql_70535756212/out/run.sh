#!/bin/bash
set -e

# Get CPU count, default to 1 if unable to determine
CPU_COUNT=$(nproc 2>/dev/null || echo 1)

# Run tests with dynamic CPU count
yarn test-ci --minWorkers=1 --maxWorkers="$CPU_COUNT"