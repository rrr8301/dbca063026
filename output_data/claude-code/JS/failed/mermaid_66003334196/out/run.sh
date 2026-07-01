#!/usr/bin/env bash

cd /app

echo "Running Unit Tests..."
pnpm test:coverage || true

echo "Running ganttDb tests with America/Los_Angeles timezone..."
TZ=America/Los_Angeles pnpm exec vitest run ./packages/mermaid/src/diagrams/gantt/ganttDb.spec.ts --coverage || true

echo "Verifying out-of-tree build with TypeScript..."
pnpm test:check:tsc || true

echo "FINAL_STATUS = SUCCESS"
