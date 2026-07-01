#!/bin/bash
set -e

# Navigate to the project directory
cd /workspace/dexter

# Install dependencies with Bun
bun install --frozen-lockfile --ignore-scripts

# Run tests
bun test