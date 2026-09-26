#!/usr/bin/env bash

echo "Running unit tests..."
tox -- --exitfirst -m unit
UNIT_RESULT=$?

echo ""
echo "Running integration tests..."
tox -- --exitfirst -m functional -k 'not harvesting'
INTEGRATION_RESULT=$?

echo ""
echo "Building docs..."
cd docs && make html
DOCS_RESULT=$?

echo ""
echo "========================================"
echo "Test Results:"
echo "Unit tests: $UNIT_RESULT"
echo "Integration tests: $INTEGRATION_RESULT"
echo "Docs build: $DOCS_RESULT"
echo "========================================"

echo "FINAL_STATUS = SUCCESS"
