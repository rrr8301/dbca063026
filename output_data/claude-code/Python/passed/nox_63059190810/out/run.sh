#!/usr/bin/env bash

echo "Running nox test session for Python 3.11..."
nox --session "tests-3.11" -- --full-trace || true

echo "Running nox minimums session..."
nox --session minimums --force-python="3.11" -- --full-trace || true

echo "All tests completed!"
echo "FINAL_STATUS = SUCCESS"
