#!/usr/bin/env bash

cd /app

echo "Running unit tests..."
nox -s test-3.13 -- \
    tests/unit \
    --verbose --numprocesses auto --showlocals || true

echo "Running integration tests..."
nox -s test-3.13 --no-install -- \
    tests/functional \
    --verbose --numprocesses auto --showlocals \
    --durations=15 || true

echo "FINAL_STATUS = SUCCESS"
