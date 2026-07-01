#!/bin/bash

# Install project dependencies
# Use --no-frozen-lockfile if pnpm-lock.yaml is absent
if [ ! -f pnpm-lock.yaml ]; then
  pnpm install --no-frozen-lockfile
else
  pnpm install --frozen-lockfile
fi

# Ensure TypeScript and necessary type declarations are installed
pnpm add -D typescript @types/node @types/jest

# Install missing type declarations
pnpm add -D @types/commander @types/interpret @types/webpack-merge @types/node-plop @types/cross-spawn @types/ejs @types/inquirer @types/envinfo @types/fastest-levenshtein

# Install missing modules
pnpm add commander interpret webpack-merge node-plop @discoveryjs/json-ext @inquirer/select @inquirer/expand cross-spawn ejs envinfo fastest-levenshtein

# Prepare environment for tests
npm run build -- --sourceMap true

# Run tests and generate coverage
npm run test:coverage -- --ci