#!/usr/bin/env bash

set -e

cd /app

# Set test variables
export TESTS=':nbrowser-^[A-D]:'
export MOCHA_WEBDRIVER_LOGDIR=/tmp/test-logs/webdriver
export TESTDIR=/tmp/test-logs
export GVISOR_FLAGS="-unprivileged -ignore-cgroups"
export GVISOR_EXTRA_DIRS=/opt

# Create log directories
mkdir -p $MOCHA_WEBDRIVER_LOGDIR
mkdir -p $TESTDIR

# Export GREP_TESTS for the nbrowser test filter
export GREP_TESTS=$(echo $TESTS | sed "s/.*:nbrowser-\([^:]*\).*/\1/")

# Run the nbrowser tests
MOCHA_WEBDRIVER_SKIP_CLEANUP=1 MOCHA_WEBDRIVER_HEADLESS=1 yarn run test:nbrowser --parallel --jobs 3

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
