#!/bin/bash

set -e

echo "=========================================="
echo "Starting JavaScript Tests and Code Style"
echo "=========================================="

# Change to repo directory
cd /repo

# Install dependencies (already done in Dockerfile, but ensure it's fresh)
echo "📦 Installing dependencies..."
npm ci

# Run tests
echo "🧪 Running tests..."
npm run test
TEST_RESULT=$?

# Run code style check
echo "💄 Running code style check..."
npm run check-style
STYLE_RESULT=$?

echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "Tests exit code: $TEST_RESULT"
echo "Code style exit code: $STYLE_RESULT"

# Exit with failure if either tests or style check failed
if [ $TEST_RESULT -ne 0 ] || [ $STYLE_RESULT -ne 0 ]; then
    echo "❌ Some checks failed"
    exit 1
fi

echo "✅ All checks passed"
exit 0