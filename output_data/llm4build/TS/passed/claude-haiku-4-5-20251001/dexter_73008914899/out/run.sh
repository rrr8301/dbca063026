#!/bin/bash
set -e

# Navigate to the project directory (if needed)
cd /workspace

# Install dependencies with frozen lockfile and ignore scripts
bun install --frozen-lockfile --ignore-scripts

# Run tests
bun test