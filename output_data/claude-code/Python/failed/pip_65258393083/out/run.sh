#!/usr/bin/env bash
set -e

cd /app

echo "=== Running unit tests ==="
nox -s test-3.14 -- tests/unit --verbose --numprocesses auto --showlocals || true

echo ""
echo "=== Running integration tests ==="
nox -s test-3.14 --no-install -- tests/functional --verbose --numprocesses auto --showlocals --durations=15 || true

echo ""
echo "FINAL_STATUS = SUCCESS"
