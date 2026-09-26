#!/bin/bash

set -e

# Enable error handling - continue on test failures but track them
TEST_FAILED=0

# Configure git with dummy values (since we skip the GitHub Actions)
git config --global user.name "CLI Bot"
git config --global user.email "cli-bot@example.com"

# Install dependencies with retry logic
echo "Installing dependencies with yarn..."
MAX_RETRIES=3
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if yarn install --frozen-lockfile; then
        echo "Yarn install succeeded"
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo "Yarn install failed, retrying... (attempt $((RETRY_COUNT + 1))/$MAX_RETRIES)"
            sleep 5
        else
            echo "Yarn install failed after $MAX_RETRIES attempts"
            exit 1
        fi
    fi
done

# Build the project
echo "Building project..."
yarn build || { echo "Build failed"; TEST_FAILED=1; }

# Run integration tests
echo "Running CLI integration tests..."
export OCLIF_INTEGRATION_MODULE_TYPE=CommonJS
export OCLIF_INTEGRATION_PACKAGE_MANAGER=yarn

if yarn test:integration:cli; then
    echo "Integration tests passed"
else
    echo "Integration tests failed"
    TEST_FAILED=1
fi

# Exit with appropriate code
if [ $TEST_FAILED -eq 1 ]; then
    echo "Some tests failed"
    exit 1
fi

echo "All tests completed successfully"
exit 0