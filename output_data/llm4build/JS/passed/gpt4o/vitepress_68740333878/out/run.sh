#!/bin/bash

# Install project dependencies
pnpm install

# Run checks
pnpm check

# Ensure all tests are executed
set +e
pnpm test
set -e