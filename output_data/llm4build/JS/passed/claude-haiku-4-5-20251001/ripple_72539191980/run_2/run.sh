#!/bin/bash
set -e

# Clone the repository into a temporary location if workspace is empty
if [ ! -f "/workspace/package.json" ]; then
    # Change to parent directory before removing workspace
    cd /
    # Remove the empty workspace directory
    rm -rf /workspace
    # Clone the repository
    git clone https://github.com/PLACEHOLDER_REPO_URL.git /workspace
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