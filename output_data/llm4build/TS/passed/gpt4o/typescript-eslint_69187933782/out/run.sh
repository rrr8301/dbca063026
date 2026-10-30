#!/bin/bash

# Install project dependencies
pnpm install --frozen-lockfile

# Build the project
pnpm exec nx run-many --target=build --parallel --exclude=website --exclude=website-eslint

# Run unit tests with coverage
pnpm exec nx test eslint-plugin -- --shard=4/4 --coverage || true

# Run unit tests without coverage
pnpm exec nx test eslint-plugin -- --shard=4/4 || true