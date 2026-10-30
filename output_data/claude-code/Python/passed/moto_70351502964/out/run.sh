#!/usr/bin/env bash

set -e

# Run tests with TESTS_SKIP_REQUIRES_DOCKER enabled
export TESTS_SKIP_REQUIRES_DOCKER=true

cd /app
pytest tests

echo "FINAL_STATUS = SUCCESS"
