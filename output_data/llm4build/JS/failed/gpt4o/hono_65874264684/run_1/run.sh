#!/bin/bash

# Activate environment variables if needed
# (Assuming .tool-versions is used to manage versions)

# Install project dependencies
bun install --frozen-lockfile

# Run formatting, linting, and tests
bun run format
bun run lint
bun run editorconfig-checker -format github-actions
bun run build
bun run test