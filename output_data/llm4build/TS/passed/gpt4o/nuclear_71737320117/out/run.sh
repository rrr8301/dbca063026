#!/bin/bash

# Install project dependencies
pnpm install --frozen-lockfile

# Lint the project
pnpm lint

# Run tests
pnpm test

# Build the project
pnpm build