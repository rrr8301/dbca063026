#!/bin/bash

# Install project dependencies
pnpm install

# Extract compiled artifacts (assuming they are built from source)
# Placeholder for actual build commands if needed

# Run tests
pn test

# Ensure all test cases are executed
set +e
pn test
set -e