#!/bin/bash
set -e

# Install npm dependencies
npm ci

# Install Playwright browsers with system dependencies
npx playwright install --with-deps chromium

# Build app dependencies
npm run build:app-deps

# Run app unit tests
npm run test --workspace=@getpaseo/app