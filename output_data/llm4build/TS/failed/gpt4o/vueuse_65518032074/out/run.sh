#!/bin/bash

# Build the project
nr build

# Typecheck
nr typecheck

# Run tests
set +e  # Continue on errors
pnpm run test:cov
pnpm run test:browser
pnpm run test:server
pnpm test:attw
set -e  # Stop on errors