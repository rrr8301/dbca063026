#!/bin/bash
set -e

# Clone the repository
if [ ! -d "/workspace/.git" ]; then
    git clone https://github.com/PLACEHOLDER_REPO_URL.git /workspace || true
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