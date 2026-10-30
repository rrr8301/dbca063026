#!/bin/bash
set -e

# Source nvm to make node/npm available
export NVM_DIR=/opt/nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Navigate to project root
cd /workspace

# Install dependencies
echo "Installing dependencies..."
npm install

# Run test:sources
echo "Running test:sources..."
npm run test:sources || TEST_SOURCES_FAILED=1

# Run test:types
echo "Running test:types..."
npm run test:types || TEST_TYPES_FAILED=1

# Exit with failure if any test failed
if [ -n "$TEST_SOURCES_FAILED" ] || [ -n "$TEST_TYPES_FAILED" ]; then
    echo "One or more test suites failed"
    exit 1
fi

echo "All tests passed!"
exit 0