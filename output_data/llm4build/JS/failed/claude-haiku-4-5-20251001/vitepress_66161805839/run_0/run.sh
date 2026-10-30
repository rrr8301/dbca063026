#!/bin/bash
set -e

# Install project dependencies with Playwright browser download skipped
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
pnpm install

# Install Playwright chromium browser
pnpm playwright install chromium

# Run checks
pnpm check