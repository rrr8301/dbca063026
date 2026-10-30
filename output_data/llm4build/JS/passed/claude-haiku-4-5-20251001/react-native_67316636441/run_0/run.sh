#!/bin/bash

set -e

# Print Node and Yarn versions for debugging
echo "Node.js version:"
node --version
echo "Yarn version:"
yarn --version

# Install dependencies with retry logic (matching GitHub Actions behavior)
echo "Installing dependencies..."
MAX_ATTEMPTS=2
ATTEMPT=0
WAIT_TIME=20

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if yarn install --non-interactive --frozen-lockfile; then
        echo "Yarn install succeeded"
        break
    else
        echo "yarn install failed. Retrying in $WAIT_TIME seconds..."
        sleep $WAIT_TIME
        ATTEMPT=$((ATTEMPT + 1))
    fi
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo "All attempts to invoke yarn install failed - Aborting the workflow"
    exit 1
fi

# Run JavaScript tests
echo "Running JavaScript tests..."
node ./scripts/run-ci-javascript-tests.js --maxWorkers 2

echo "JavaScript tests completed successfully"