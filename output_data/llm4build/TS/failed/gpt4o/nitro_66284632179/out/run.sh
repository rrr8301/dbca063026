#!/bin/bash

# Activate environment (if any specific activation is needed, add here)

# Install project dependencies
pnpm install

# Run linting and type checking
pnpm stub && pnpm lint
pnpm typecheck

# Run tests and ensure all tests are executed
pnpm vitest run test/unit || true
pnpm vitest run test/minimal || true