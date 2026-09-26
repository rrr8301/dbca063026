#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Install project dependencies using pnpm with frozen lockfile
pnpm install --frozen-lockfile

# Run CI tests for framework
pnpm test:ci