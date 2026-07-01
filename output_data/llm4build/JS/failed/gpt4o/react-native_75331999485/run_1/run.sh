#!/bin/bash

# Activate environment
set -e

# Run JavaScript tests
node ./scripts/run-ci-javascript-tests.js --maxWorkers 2