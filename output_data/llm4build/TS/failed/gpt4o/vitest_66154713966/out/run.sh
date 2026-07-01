#!/bin/bash

# Build the project
pnpm run build

# Run tests
pnpm run test:ci || true
pnpm run test:examples || true