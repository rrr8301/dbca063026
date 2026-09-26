#!/bin/bash

# Activate environment variables if needed (none specified)

# Install project dependencies
pnpm install --frozen-lockfile

# Install Chromium for Playwright
pnpm playwright install chromium

# Run tests and ensure all tests are executed
set +e  # Do not exit immediately on error
pnpm test
EXIT_CODE=$?

# Exit with the test command's exit code
exit $EXIT_CODE