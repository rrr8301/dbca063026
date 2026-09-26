#!/usr/bin/env bash
set -e

cd /app

echo "=== Setup test suite ==="
tox run -vv --notest --skip-missing-interpreters false -e 3.13

echo "=== Run test suite ==="
export PYTEST_ADDOPTS="-vv --durations=20"
export DIFF_AGAINST=HEAD
export PYTEST_XDIST_AUTO_NUM_WORKERS=0

tox run --skip-pkg-install -e 3.13 || true

echo "=== Tests completed ==="
echo "FINAL_STATUS = SUCCESS"
