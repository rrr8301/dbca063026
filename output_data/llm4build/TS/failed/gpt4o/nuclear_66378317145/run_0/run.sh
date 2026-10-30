#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies
pnpm install --frozen-lockfile

# Run lint
pnpm lint

# Run tests
pnpm test