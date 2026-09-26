#!/bin/bash

set -e

# Track test results
BACKEND_UNIT_RESULT=0
BACKEND_INTEGRATION_RESULT=0
NODES_UNIT_RESULT=0
FRONTEND_SHARD1_RESULT=0
FRONTEND_SHARD2_RESULT=0

echo "=========================================="
echo "n8n Unit Tests - Local Build"
echo "=========================================="

# Verify turbo configuration exists
if [ ! -f "turbo.json" ] && [ ! -f "turbo.jsonc" ]; then
    echo "❌ Error: turbo.json or turbo.jsonc not found in workspace root"
    exit 1
fi

# Install dependencies
echo ""
echo "Installing dependencies..."
pnpm install --frozen-lockfile

# Backend Unit Tests
echo ""
echo "=========================================="
echo "Running Backend Unit Tests..."
echo "=========================================="
pnpm test:ci:backend:unit --summarize || BACKEND_UNIT_RESULT=$?
if [ $BACKEND_UNIT_RESULT -ne 0 ]; then
    echo "❌ Backend Unit Tests FAILED"
else
    echo "✅ Backend Unit Tests PASSED"
fi

# Backend Integration Tests
echo ""
echo "=========================================="
echo "Running Backend Integration Tests..."
echo "=========================================="
pnpm test:ci:backend:integration --summarize || BACKEND_INTEGRATION_RESULT=$?
if [ $BACKEND_INTEGRATION_RESULT -ne 0 ]; then
    echo "❌ Backend Integration Tests FAILED"
else
    echo "✅ Backend Integration Tests PASSED"
fi

# Nodes Unit Tests
echo ""
echo "=========================================="
echo "Running Nodes Unit Tests..."
echo "=========================================="
pnpm turbo test --filter=n8n-nodes-base --summarize || NODES_UNIT_RESULT=$?
if [ $NODES_UNIT_RESULT -ne 0 ]; then
    echo "❌ Nodes Unit Tests FAILED"
else
    echo "✅ Nodes Unit Tests PASSED"
fi

# Frontend Unit Tests - Shard 1/2
echo ""
echo "=========================================="
echo "Running Frontend Unit Tests (Shard 1/2)..."
echo "=========================================="
VITEST_SHARD=1/2 pnpm test:ci:frontend --summarize -- --shard=1/2 || FRONTEND_SHARD1_RESULT=$?
if [ $FRONTEND_SHARD1_RESULT -ne 0 ]; then
    echo "❌ Frontend Unit Tests (Shard 1/2) FAILED"
else
    echo "✅ Frontend Unit Tests (Shard 1/2) PASSED"
fi

# Frontend Unit Tests - Shard 2/2
echo ""
echo "=========================================="
echo "Running Frontend Unit Tests (Shard 2/2)..."
echo "=========================================="
VITEST_SHARD=2/2 pnpm test:ci:frontend --summarize -- --shard=2/2 || FRONTEND_SHARD2_RESULT=$?
if [ $FRONTEND_SHARD2_RESULT -ne 0 ]; then
    echo "❌ Frontend Unit Tests (Shard 2/2) FAILED"
else
    echo "✅ Frontend Unit Tests (Shard 2/2) PASSED"
fi

# Summary
echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "Backend Unit Tests:        $([ $BACKEND_UNIT_RESULT -eq 0 ] && echo '✅ PASSED' || echo '❌ FAILED')"
echo "Backend Integration Tests: $([ $BACKEND_INTEGRATION_RESULT -eq 0 ] && echo '✅ PASSED' || echo '❌ FAILED')"
echo "Nodes Unit Tests:          $([ $NODES_UNIT_RESULT -eq 0 ] && echo '✅ PASSED' || echo '❌ FAILED')"
echo "Frontend Tests (Shard 1/2): $([ $FRONTEND_SHARD1_RESULT -eq 0 ] && echo '✅ PASSED' || echo '❌ FAILED')"
echo "Frontend Tests (Shard 2/2): $([ $FRONTEND_SHARD2_RESULT -eq 0 ] && echo '✅ PASSED' || echo '❌ FAILED')"
echo "=========================================="

# Determine overall exit code
OVERALL_RESULT=0
if [ $BACKEND_UNIT_RESULT -ne 0 ] || \
   [ $BACKEND_INTEGRATION_RESULT -ne 0 ] || \
   [ $NODES_UNIT_RESULT -ne 0 ] || \
   [ $FRONTEND_SHARD1_RESULT -ne 0 ] || \
   [ $FRONTEND_SHARD2_RESULT -ne 0 ]; then
    OVERALL_RESULT=1
    echo "❌ Some tests FAILED"
else
    echo "✅ All tests PASSED"
fi

exit $OVERALL_RESULT