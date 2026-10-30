#!/bin/bash

# Activate Bun environment
export BUN_INSTALL="/root/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Install project dependencies
bun install --frozen-lockfile --ignore-scripts

# Run tests
bun test