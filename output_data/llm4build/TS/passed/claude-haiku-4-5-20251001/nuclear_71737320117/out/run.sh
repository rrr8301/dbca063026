#!/bin/bash

set -e

# Source Rust environment
. $HOME/.cargo/env

# Print environment info
echo "=== Environment Info ==="
echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"
echo "pnpm version: $(pnpm --version)"
echo "Rust version: $(rustc --version)"
echo "Cargo version: $(cargo --version)"
echo ""

# Install project dependencies
echo "=== Installing dependencies ==="
pnpm install --frozen-lockfile

# Run linting
echo ""
echo "=== Running linter ==="
pnpm lint || LINT_FAILED=1

# Run tests
echo ""
echo "=== Running tests ==="
pnpm test || TEST_FAILED=1

# Run build
echo ""
echo "=== Building project ==="
# Set placeholder values for secrets if not provided
export TAURI_SIGNING_PRIVATE_KEY="${TAURI_SIGNING_PRIVATE_KEY:-placeholder_key}"
export TAURI_SIGNING_PRIVATE_KEY_PASSWORD="${TAURI_SIGNING_PRIVATE_KEY_PASSWORD:-placeholder_password}"
export CODECOV_TOKEN="${CODECOV_TOKEN:-placeholder_token}"

pnpm build || BUILD_FAILED=1

# Summary
echo ""
echo "=== Build Summary ==="
if [ -z "$LINT_FAILED" ] && [ -z "$TEST_FAILED" ] && [ -z "$BUILD_FAILED" ]; then
    echo "✓ All checks passed!"
    exit 0
else
    echo "✗ Some checks failed:"
    [ -n "$LINT_FAILED" ] && echo "  - Linting failed"
    [ -n "$TEST_FAILED" ] && echo "  - Tests failed"
    [ -n "$BUILD_FAILED" ] && echo "  - Build failed"
    exit 1
fi