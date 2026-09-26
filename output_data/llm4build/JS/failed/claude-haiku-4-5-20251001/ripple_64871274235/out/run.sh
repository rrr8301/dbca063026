#!/bin/sh

set -e

# Print Node and pnpm versions for debugging
echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"
echo "pnpm version: $(pnpm --version)"
echo "Python version: $(python3 --version)"

# Install dependencies with pnpm (frozen lockfile for reproducibility)
echo "Installing dependencies..."
pnpm install --prod false --frozen-lockfile

# Build cli package
echo "Building cli package..."
cd ./packages/cli
pnpm build
cd ../..

# Build eslint-parser package
echo "Building eslint-parser package..."
cd ./packages/eslint-parser
pnpm build
cd ../..

# Run tests (ensure all tests run even if some fail)
echo "Running tests..."
pnpm test || TEST_FAILED=1

# Exit with appropriate code
if [ "$TEST_FAILED" = "1" ]; then
  echo "Tests failed!"
  exit 1
fi

echo "All tests passed!"
exit 0