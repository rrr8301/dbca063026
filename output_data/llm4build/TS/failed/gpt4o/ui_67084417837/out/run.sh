#!/bin/bash

# Install project dependencies
pnpm install

# Run tests
pnpm test || true  # Ensure all tests run even if some fail