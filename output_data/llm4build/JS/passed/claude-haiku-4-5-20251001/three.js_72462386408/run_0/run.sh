#!/bin/bash

set -e

# Print Node and npm versions for debugging
echo "=== Node.js and npm versions ==="
node --version
npm --version

# Install dependencies using npm ci (clean install)
echo "=== Installing dependencies ==="
npm ci

# Run lint testing
echo "=== Lint testing ==="
npm run lint || LINT_FAILED=1

# Run unit testing
echo "=== Unit testing ==="
npm run test-unit || UNIT_FAILED=1

# Run unit addons testing
echo "=== Unit addons testing ==="
npm run test-unit-addons || UNIT_ADDONS_FAILED=1

# Run examples/e2e coverage testing
echo "=== Examples ready for release ==="
npm run test-e2e-cov || E2E_FAILED=1

# Summary and exit with error if any test failed
echo ""
echo "=== Test Summary ==="
FAILED=0
[ -z "$LINT_FAILED" ] || { echo "❌ Lint testing failed"; FAILED=1; }
[ -z "$UNIT_FAILED" ] || { echo "❌ Unit testing failed"; FAILED=1; }
[ -z "$UNIT_ADDONS_FAILED" ] || { echo "❌ Unit addons testing failed"; FAILED=1; }
[ -z "$E2E_FAILED" ] || { echo "❌ E2E coverage testing failed"; FAILED=1; }

if [ $FAILED -eq 0 ]; then
    echo "✅ All tests passed"
fi

exit $FAILED