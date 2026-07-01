#!/bin/bash

# Install Playwright Chromium
pnpm exec playwright install chromium

# Run tests
cd ./packages/vuetify
pnpm run test -- --dir=$(dirname $(realpath $0))