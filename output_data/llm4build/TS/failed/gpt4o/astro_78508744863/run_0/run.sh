#!/bin/bash

# Install project dependencies
pnpm install

# Build packages
pnpm run build

# Run integration tests
pnpm run test:integrations