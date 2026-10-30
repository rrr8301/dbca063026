#!/usr/bin/env bash
set -e

cd /app

echo "Running dify config tests..."
uv run --project api dev/pytest/pytest_config_tests.py

echo "Running unit tests..."
uv run --project api bash dev/pytest/pytest_unit_tests.sh

echo "FINAL_STATUS = SUCCESS"
