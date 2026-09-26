#!/usr/bin/env bash

set -e

cd /app

# Run the JavaScript tests
node ./scripts/run-ci-javascript-tests.js --maxWorkers 2

echo "FINAL_STATUS = SUCCESS"
