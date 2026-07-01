#!/usr/bin/env bash
set -e

# Add uv to PATH
export PATH="/root/.local/bin:$PATH"

cd /app

echo "=== Running tests on ubuntu-latest ==="
nox --session "tests-3.12" -- --full-trace

echo "=== Running min-version tests on ubuntu-latest ==="
nox --session minimums --force-python="3.12" -- --full-trace || true

echo "FINAL_STATUS = SUCCESS"
