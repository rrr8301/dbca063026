#!/bin/bash

set -e

# Ensure Node.js is available
export NVM_DIR=/root/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Navigate to workspace
cd /workspace

# Run lint testing
echo "=== Lint testing ==="
npm run lint

# Run unit testing
echo "=== Unit testing ==="
npm run test-unit

# Run unit addons testing
echo "=== Unit addons testing ==="
npm run test-unit-addons

# Run examples ready for release (e2e coverage)
echo "=== Examples ready for release ==="
npm run test-e2e-cov

echo "All tests completed successfully!"