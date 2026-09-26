#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
TEST_EXIT_CODE=0

echo "=========================================="
echo "Installing dependencies with pnpm..."
echo "=========================================="
pnpm install

echo ""
echo "=========================================="
echo "Running tests with coverage..."
echo "=========================================="
export MUTE_REACT_ACT_WARNINGS=1
pnpm test --coverage || TEST_EXIT_CODE=$?

echo ""
echo "=========================================="
echo "Verifying committed OpenAPI test fixtures..."
echo "=========================================="

# Check if there are uncommitted changes in the OpenAPI test fixtures
if [[ -n "$(git status --porcelain -- packages/openapi/test/routers/)" ]]; then
    echo "ERROR: Generated files in packages/openapi/test/routers/ are out of date."
    echo "Run 'pnpm -C packages/openapi codegen' locally and commit the resulting changes."
    echo ""
    echo "Current status:"
    git status --short -- packages/openapi/test/routers/
    echo ""
    echo "Diff for generated fixtures:"
    git --no-pager diff -- packages/openapi/test/routers/
    echo ""
    TEST_EXIT_CODE=1
else
    echo "✓ OpenAPI test fixtures are up to date"
fi

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="

if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "✓ All tests passed"
    exit 0
else
    echo "✗ Tests failed with exit code: $TEST_EXIT_CODE"
    exit $TEST_EXIT_CODE
fi