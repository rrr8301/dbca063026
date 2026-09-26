#!/usr/bin/env bash

set -e

cd /app

# Run unit tests
./out/Release/unit_tests

echo "FINAL_STATUS = SUCCESS"
