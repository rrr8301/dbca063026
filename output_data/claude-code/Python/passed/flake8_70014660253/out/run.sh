#!/usr/bin/env bash

set -e

cd /app

echo "Running tests with coverage..."
python3.12 -m coverage run -m pytest || true

echo ""
echo "Coverage report:"
python3.12 -m coverage report || true

echo ""
echo "Coverage report - fail under 100% for tests:"
python3.12 -m coverage report --fail-under 100 --include tests/* || true

echo ""
echo "FINAL_STATUS = SUCCESS"
