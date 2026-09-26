#!/bin/bash

# Install project dependencies
pnpm install --frozen-lockfile

# Generate code
pnpm buf generate --template buf.ts.gen.yaml

# Build the project
pnpm run --filter ./composition --filter ./connect --filter ./shared build

# Run tests
pnpm run --filter composition test:coverage

# Lint the project
pnpm run --filter composition lint