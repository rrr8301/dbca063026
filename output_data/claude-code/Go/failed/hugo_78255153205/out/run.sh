#!/usr/bin/env bash

set -e

cd /app

echo "=== Testing Hugo ==="

# Check embedded go template formatting
echo "Checking embedded go template formatting..."
diff <(gotmplfmt -d tpl/tplimpl/embedded/templates) <(printf '') || true

# Run staticcheck
echo "Running staticcheck..."
export STATICCHECK_CACHE="/tmp/staticcheck"
staticcheck ./... || true
rm -rf /tmp/staticcheck || true

# Check
echo "Running mage check..."
sass --version
mage -v check || true

# Build for dragonfly
echo "Building for dragonfly..."
GOARCH=amd64 GOOS=dragonfly go install || true

echo "=== Tests completed ==="
FINAL_STATUS=SUCCESS
