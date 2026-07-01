#!/bin/bash

set -e

# Output Node and NPM versions
echo "Node.js version: $(node -v)"
echo "NPM version: $(npm -v)"

# Navigate to workspace
cd /workspace

# Install dependencies
echo "Installing dependencies..."
npm install

# Configure npm loglevel
npm config set loglevel error

# Remove non-test dependencies
echo "Removing non-test dependencies..."
npm rm --silent --save-dev connect-redis || true

# Run tests
echo "Running tests..."
npm run test-ci || TEST_FAILED=1

# Exit with appropriate code
if [ "$TEST_FAILED" = "1" ]; then
    echo "Tests failed!"
    exit 1
fi

echo "All tests completed successfully!"
exit 0