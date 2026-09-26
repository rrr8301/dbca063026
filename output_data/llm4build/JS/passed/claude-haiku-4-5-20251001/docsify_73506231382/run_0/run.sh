#!/bin/bash
set -e

# Navigate to the docsify directory (where package.json is located)
cd /workspace/docsify

# Install dependencies (npm ci is preferred for CI environments)
echo "Installing dependencies..."
npm ci --ignore-scripts

# Build the project
echo "Building project..."
npm run build

# Run unit tests
echo "Running unit tests..."
npm run test:unit -- --ci --runInBand || UNIT_TEST_FAILED=1

# Run integration tests
echo "Running integration tests..."
npm run test:integration -- --ci --runInBand || INTEGRATION_TEST_FAILED=1

# Run consumption tests
echo "Running consumption tests..."
npm run test:consume-types || CONSUME_TYPES_FAILED=1

# Report results
echo ""
echo "========== Test Summary =========="
if [ -z "$UNIT_TEST_FAILED" ]; then
  echo "✓ Unit tests passed"
else
  echo "✗ Unit tests failed"
fi

if [ -z "$INTEGRATION_TEST_FAILED" ]; then
  echo "✓ Integration tests passed"
else
  echo "✗ Integration tests failed"
fi

if [ -z "$CONSUME_TYPES_FAILED" ]; then
  echo "✓ Consumption tests passed"
else
  echo "✗ Consumption tests failed"
fi

# Exit with failure if any test suite failed
if [ -n "$UNIT_TEST_FAILED" ] || [ -n "$INTEGRATION_TEST_FAILED" ] || [ -n "$CONSUME_TYPES_FAILED" ]; then
  exit 1
fi

exit 0