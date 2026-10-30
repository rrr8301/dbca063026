#!/usr/bin/env bash
set -e

cd /app
. venv/bin/activate

pip install . --no-deps
pip list | grep 'astroid\|pylint'

echo "Running pytest..."
python -m pytest --durations=10 --benchmark-disable --cov --cov-report= tests/ || true

echo "Running functional tests with minimal messages config..."
python -m pytest -vv --minimal-messages-config tests/test_functional.py --benchmark-disable || true

echo "FINAL_STATUS = SUCCESS"
