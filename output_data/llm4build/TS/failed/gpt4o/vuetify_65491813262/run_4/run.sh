#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Install Playwright Chromium
pnpm exec playwright install chromium

# Navigate to the vuetify package directory
cd ./packages/vuetify

# Run tests
pnpm run test