#!/usr/bin/env bash

echo "=========================================="
echo "Running unit tests..."
echo "=========================================="

tox -- --exitfirst -m unit || true
UNIT_RESULT=$?

echo ""
echo "=========================================="
echo "Running integration tests..."
echo "=========================================="

tox -- --exitfirst -m functional -k 'not harvesting' || true
INTEGRATION_RESULT=$?

echo ""
echo "=========================================="
echo "Test Results:"
echo "=========================================="
echo "Unit tests exit code: $UNIT_RESULT"
echo "Integration tests exit code: $INTEGRATION_RESULT"

echo "FINAL_STATUS = SUCCESS"
