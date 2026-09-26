#!/bin/bash

# Set git to use LF
git config --global core.autocrlf false
git config --global core.eol lf

# Install project dependencies
pnpm install

# Build the project
pnpm build

# Run tests
pnpm test