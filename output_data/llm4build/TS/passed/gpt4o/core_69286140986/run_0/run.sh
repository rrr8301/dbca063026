#!/bin/bash

# Install project dependencies
pnpm install

# Run unit tests
pnpm run test-unit compiler
pnpm run test-unit server-renderer