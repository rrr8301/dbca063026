#!/usr/bin/env bash
set -e

cd /app

echo "Building with Python build..."
python -m build
shasum -a 256 dist/*

echo "Checking manifest..."
check-manifest

echo "Running pytest..."
python -m pytest --color=yes -raXxs --cov --cov-report=xml --maxfail=15

echo "FINAL_STATUS = SUCCESS"
