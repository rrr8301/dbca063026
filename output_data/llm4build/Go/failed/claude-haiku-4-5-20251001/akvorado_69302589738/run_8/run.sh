#!/bin/bash
set -e

# Print Node.js and Go versions for debugging
echo "Node.js version:"
node --version
echo "npm version:"
npm --version
echo "Go version:"
go version

# Verify go.mod directive
echo "Checking go.mod directive..."
GO_DIRECTIVE=$(go mod edit -json | jq -r .Go)
echo "Go directive: $GO_DIRECTIVE"

if ! echo "$GO_DIRECTIVE" | grep -Pxq '1\.\d+'; then
    echo "^^^^ Incorrect go directive in go.mod: use only \`minor.major'."
    exit 1
fi

# Ensure all scripts have execute permissions
echo "Setting execute permissions on scripts..."
chmod -R +x ./bin/ 2>/dev/null || true
chmod -R +x ./common/schema/*.sh 2>/dev/null || true
find . -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true

# Clean and reinstall node modules to fix native binding issues
echo "Cleaning and reinstalling node modules..."
rm -rf console/frontend/node_modules console/frontend/package-lock.json
cd console/frontend
pnpm install --force
cd /workspace

# Build
echo "Building..."
make

echo "Running akvorado version..."
./bin/akvorado version

# Run tests
echo "Running Go tests..."
make test-go

echo "All tests passed!"