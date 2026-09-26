#!/bin/bash

# Activate environment variables if needed
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

# Install project dependencies
pnpm install --frozen-lockfile

# Install Playwright Chromium
pnpm playwright install chromium

# Run tests
set +e  # Continue execution even if some tests fail
pnpm test