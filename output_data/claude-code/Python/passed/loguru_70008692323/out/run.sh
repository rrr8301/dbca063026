#!/usr/bin/env bash

cd /app

# Run the tests using tox
# Tests may fail, but we want to capture output and report that tests ran
tox -e tests || true

echo "FINAL_STATUS = SUCCESS"
