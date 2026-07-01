#!/bin/bash

# Disable git crlf
git config --global core.autocrlf false

# Clone the repository (assuming the repo URL is known)
# git clone <repository-url> .

# Install dependencies
pnpm install

# Build packages
pnpm run build

# Run tests
pnpm run test:astro