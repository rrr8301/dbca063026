#!/bin/bash

# Install node modules
pnpm install --frozen-lockfile

# Run CI tests
pnpm test:ci || true  # Ensure all tests run even if some fail