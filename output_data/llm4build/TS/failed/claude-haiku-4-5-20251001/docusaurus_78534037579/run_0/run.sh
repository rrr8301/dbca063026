#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Install dependencies with retries (as per YAML)
yarn install --frozen-lockfile || yarn install --frozen-lockfile || yarn install --frozen-lockfile

# Run tests
yarn test