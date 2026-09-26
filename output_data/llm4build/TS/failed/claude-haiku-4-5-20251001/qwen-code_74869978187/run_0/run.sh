#!/bin/bash

set -e

# Configure npm for rate limiting
npm config set fetch-retry-mintimeout 20000
npm config set fetch-retry-maxtimeout 120000
npm config set fetch-retries 5
npm config set fetch-timeout 300000

# Install dependencies
npm ci --prefer-offline --no-audit --progress=false

# Build project
npm run build

# Run tests and generate reports
export NO_COLOR=true
npm run test:ci