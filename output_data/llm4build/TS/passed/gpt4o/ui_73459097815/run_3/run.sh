#!/bin/bash

# Source the bashrc to ensure Bun is in the PATH
source ~/.bashrc

# Set environment variables
export NEXT_PUBLIC_APP_URL=http://localhost:4000
export NEXT_PUBLIC_V0_URL=https://v0.dev

# Run tests
pnpm test