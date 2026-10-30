#!/usr/bin/env bash
set -e

cd /app/build.mbed
ctest --output-on-failure

echo "FINAL_STATUS = SUCCESS"
