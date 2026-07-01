#!/bin/bash
set -e

# Assume the repository is already mounted or copied into /workspace
# If /workspace is empty, exit with error (don't try to clone with placeholder URL)
if [ ! -f "/workspace/package.json" ]; then
    echo "Error: /workspace/package.json not found"
    echo "Please mount or copy the repository into /workspace"
    exit 1
fi

cd /workspace

# Install project dependencies
pnpm install --prod false --frozen-lockfile

# Build cli package
cd /workspace/packages/cli
pnpm build

# Build eslint-parser package
cd /workspace/packages/eslint-parser
pnpm build

# Run tests
cd /workspace
pnpm test