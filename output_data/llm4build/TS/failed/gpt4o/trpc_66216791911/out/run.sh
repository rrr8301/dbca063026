#!/bin/bash

# Activate environment variables if needed (none specified)

# Install project dependencies
pnpm install

# Run tests with coverage
MUTE_REACT_ACT_WARNINGS=1 pnpm test -- --coverage || true

# Ensure all tests are executed, even if some fail