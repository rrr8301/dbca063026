#!/bin/bash

# Activate environment (if any specific activation is needed, e.g., nvm)
source ~/.bashrc

# Navigate to the web directory
cd /app/web

# Install and build TypeScript SDK
cd ../open-api/typescript-sdk
pnpm install --frozen-lockfile && pnpm build

# Return to the web directory
cd /app/web

# Install project dependencies
pnpm install --frozen-lockfile

# Run TypeScript checks
pnpm check:typescript

# Run unit tests and ensure all tests are executed
pnpm test || true