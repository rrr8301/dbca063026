#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Install pnpm globally (ensure it's available)
npm install -g pnpm

# Create pn alias
alias pn=pnpm

# Set Node.js version to 22.13.0 using pnpm runtime
pnpm runtime -g set node 22.13.0

# Verify npm version
npm --version

# Install project dependencies
pnpm install

# Handle compiled artifacts if they exist
if [ -f "compiled.tar.gz" ]; then
  echo "Extracting compiled artifacts..."
  tar -xzf compiled.tar.gz
else
  echo "Note: compiled.tar.gz not found. Assuming artifacts are built from source or not required."
fi

# Determine test scope
echo "Determining test scope..."
pnpm test:scope

# Run all tests
echo "Running tests..."
pnpm test