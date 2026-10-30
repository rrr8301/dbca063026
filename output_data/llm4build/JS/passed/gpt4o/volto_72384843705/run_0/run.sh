#!/bin/bash

# Install project dependencies
make install

# Build dependencies
make build-deps

# Run tests
pnpm --filter seven test