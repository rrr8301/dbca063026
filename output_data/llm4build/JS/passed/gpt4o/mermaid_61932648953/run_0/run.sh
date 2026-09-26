#!/bin/bash

# Activate environment variables if needed
export TZ=America/Los_Angeles

# Install project dependencies
pnpm install --frozen-lockfile

# Run unit tests
pnpm test:coverage || true

# Run ganttDb tests using California timezone
pnpm exec vitest run ./packages/mermaid/src/diagrams/gantt/ganttDb.spec.ts --coverage || true

# Verify out-of-tree build with TypeScript
pnpm test:check:tsc || true