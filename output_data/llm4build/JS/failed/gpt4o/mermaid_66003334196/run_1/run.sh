#!/bin/bash

# Activate Node.js environment
source ~/.bashrc

# Install project dependencies
pnpm install --frozen-lockfile

# Run unit tests with coverage
pnpm test:coverage || true

# Run ganttDb tests with specific timezone
TZ=America/Los_Angeles pnpm exec vitest run ./packages/mermaid/src/diagrams/gantt/ganttDb.spec.ts --coverage || true

# Verify out-of-tree build with TypeScript
pnpm test:check:tsc || true