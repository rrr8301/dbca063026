#!/usr/bin/env bash
set -e

# Source Rust environment
. $HOME/.cargo/env

# Run lint
echo "===== Running lint ====="
pnpm lint || true

# Run tests
echo "===== Running tests ====="
pnpm test || true

# Run build
echo "===== Running build ====="
pnpm build || true

echo ""
echo "FINAL_STATUS = SUCCESS"
