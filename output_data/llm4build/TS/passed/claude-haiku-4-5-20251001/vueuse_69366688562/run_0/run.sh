#!/bin/bash

set -e

# Track test failures but continue execution
TEST_FAILED=0

echo "=========================================="
echo "Installing global dependencies"
echo "=========================================="
npm i -g @antfu/ni

echo "=========================================="
echo "Installing project dependencies"
echo "=========================================="
nci

echo "=========================================="
echo "Installing Playwright browsers"
echo "=========================================="
pnpm exec playwright install --with-deps

echo "=========================================="
echo "Building project"
echo "=========================================="
nr build

echo "=========================================="
echo "Running typecheck"
echo "=========================================="
nr typecheck

echo "=========================================="
echo "Running unit tests with coverage"
echo "=========================================="
if ! pnpm run test:cov; then
    echo "⚠️  Unit tests failed"
    TEST_FAILED=1
fi

echo "=========================================="
echo "Running browser tests"
echo "=========================================="
if ! pnpm run test:browser; then
    echo "⚠️  Browser tests failed"
    TEST_FAILED=1
fi

echo "=========================================="
echo "Running server tests"
echo "=========================================="
if ! pnpm run test:server; then
    echo "⚠️  Server tests failed"
    TEST_FAILED=1
fi

echo "=========================================="
echo "Test execution completed"
echo "=========================================="

if [ $TEST_FAILED -eq 1 ]; then
    echo "❌ Some tests failed"
    exit 1
else
    echo "✅ All tests passed"
    exit 0
fi