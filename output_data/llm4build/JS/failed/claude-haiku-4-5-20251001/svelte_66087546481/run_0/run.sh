#!/bin/bash
set -e

# Install project dependencies
pnpm install --frozen-lockfile

# Install Playwright chromium browser
pnpm playwright install chromium

# Run tests
pnpm test