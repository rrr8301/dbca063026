#!/bin/bash

# Install project dependencies
pnpm install

# Extract compiled artifacts (assuming they are built from source)
# Placeholder for actual build commands if needed

# Run tests
pnpm test  # Corrected from 'pn test' to 'pnpm test'

# Ensure all test cases are executed
set +e
pnpm test  # Corrected from 'pn test' to 'pnpm test'
set -e