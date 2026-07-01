#!/usr/bin/env bash

set -e

cd /app/build/test
ctest -C Release --output-on-failure

echo "FINAL_STATUS = SUCCESS"
