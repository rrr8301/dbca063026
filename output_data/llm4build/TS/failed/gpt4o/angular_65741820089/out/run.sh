#!/bin/bash

# Install node modules
pnpm install --frozen-lockfile

# Run CI tests
pnpm test:ci  # Ensure all tests run