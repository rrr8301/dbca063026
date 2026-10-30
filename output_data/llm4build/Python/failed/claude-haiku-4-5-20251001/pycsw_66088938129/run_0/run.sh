#!/bin/bash

set -e

# Set environment variable
export TOXENV=py312-sqlite

echo "TOXENV => py312-sqlite"

# Run unit tests
echo "Running unit tests..."
tox -- --exitfirst -m unit
UNIT_TEST_EXIT=$?

# Run integration tests
echo "Running integration tests..."
tox -- --exitfirst -m functional -k 'not harvesting'
INTEGRATION_TEST_EXIT=$?

# Exit with failure if either test suite failed
if [ $UNIT_TEST_EXIT -ne 0 ] || [ $INTEGRATION_TEST_EXIT -ne 0 ]; then
    exit 1
fi

exit 0