#!/usr/bin/env bash
set -e

cd /app

echo "Running tests with tox..."
tox

echo "Installing pyink..."
pip install pyink==24.3.0 --break-system-packages

echo "Running pyink check..."
pyink --check .

echo "FINAL_STATUS = SUCCESS"
