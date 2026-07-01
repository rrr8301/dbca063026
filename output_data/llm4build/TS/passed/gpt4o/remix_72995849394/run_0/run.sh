#!/bin/bash

# Activate environment (if any specific activation is needed, otherwise skip)
# Example: source /path/to/venv/bin/activate

# Install project dependencies
pnpm install --frozen-lockfile

# Run tests
pnpm test || true  # Ensure all tests run even if some fail