#!/usr/bin/env bash
set -e

cd /app

# Run tests
make check VERBOSE=yes
git diff --exit-code

echo "FINAL_STATUS = SUCCESS"
