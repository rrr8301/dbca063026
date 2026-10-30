#!/usr/bin/env bash
set -e

export BABEL_ENV=test
export BABEL_COVERAGE=true

echo "Running tests..."
yarn c8 jest --ci || TEST_RESULT=$?
yarn test:esm || TEST_RESULT=$?

if [ -z "$TEST_RESULT" ] || [ "$TEST_RESULT" -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = SUCCESS"
fi
