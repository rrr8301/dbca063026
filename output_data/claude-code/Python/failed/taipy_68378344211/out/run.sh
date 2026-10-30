#!/usr/bin/env bash
set -e

cd /app

echo "Running pytest with coverage..."
pipenv run pytest --cov=taipy --cov-report=xml:/tmp/coverage.xml --cov-config=.coveragerc

echo "Tests completed successfully"
echo "FINAL_STATUS = SUCCESS"
