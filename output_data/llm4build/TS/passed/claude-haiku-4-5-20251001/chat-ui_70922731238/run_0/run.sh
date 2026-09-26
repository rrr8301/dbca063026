#!/bin/bash
set -e

# Activate nvm
export NVM_DIR=/opt/nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Verify Node.js is available
node --version
npm --version

# Install dependencies (clean install from lock file)
npm ci

# Install Playwright browsers
npx playwright install

# Run tests
npm run test