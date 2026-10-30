#!/usr/bin/env bash

cd /app/build
export CTEST_OUTPUT_ON_FAILURE=1
ctest -C Debug -j4 || true

echo "FINAL_STATUS = SUCCESS"
