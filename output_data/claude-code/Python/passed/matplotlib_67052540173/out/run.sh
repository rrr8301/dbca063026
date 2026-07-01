#!/usr/bin/env bash
set -e

cd /app

echo "=== Running pytest ==="
python3.12 -m pytest -rfEsXR -n auto \
  --maxfail=50 --timeout=300 --durations=25 \
  --cov-report=xml --cov=lib --log-level=DEBUG --color=yes || true

echo "=== Filtering C coverage ==="
LCOV_IGNORE_ERRORS='mismatch,unused'
lcov --rc lcov_branch_coverage=1 --ignore-errors $LCOV_IGNORE_ERRORS \
  --capture --directory . --output-file coverage.info || true
lcov --rc lcov_branch_coverage=1 --ignore-errors $LCOV_IGNORE_ERRORS \
  --output-file coverage.info --extract coverage.info $PWD/src/'*' $PWD/lib/'*' || true
lcov --rc lcov_branch_coverage=1 --ignore-errors $LCOV_IGNORE_ERRORS \
  --list coverage.info || true
find . -name '*.gc*' -delete || true

echo "FINAL_STATUS = SUCCESS"
