#!/bin/bash

# Install project dependencies
pnpm install --frozen-lockfile

# Run tests
pnpm test:global
pnpm test:service