#!/bin/bash

# Install Playwright Chromium
pnpm exec playwright install chromium

# Run tests
cd ./packages/vuetify

# Use Node.js to determine the directory path
DIR=$(node -e "console.log(new URL('.', import.meta.url).pathname)")

pnpm run test -- --dir=$DIR