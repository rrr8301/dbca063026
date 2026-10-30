#!/usr/bin/env bash

set -e
set -o pipefail

cd /app

echo "=========================================="
echo "Running SHADE_BUILD step"
echo "=========================================="
./pulsar-build/run_integration_group_gradle.sh SHADE_BUILD

echo ""
echo "=========================================="
echo "Running SHADE_RUN step"
echo "=========================================="
./pulsar-build/run_integration_group_gradle.sh SHADE_RUN

echo ""
echo "=========================================="
echo "Tests completed successfully"
echo "=========================================="
echo "FINAL_STATUS = SUCCESS"
