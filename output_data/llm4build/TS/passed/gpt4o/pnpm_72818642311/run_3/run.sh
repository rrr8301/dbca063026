#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Install project dependencies
pnpm install --shamefully-hoist

# Run tests
pnpm run test