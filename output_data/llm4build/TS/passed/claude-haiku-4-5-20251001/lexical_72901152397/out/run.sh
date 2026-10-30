#!/bin/bash
set -e

# Activate nvm
export NVM_DIR=/root/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Verify Node.js and pnpm are available
node --version
npm --version
pnpm --version

# Install project dependencies with frozen lockfile
pnpm install --frozen-lockfile

# Run unit tests
pnpm run test-unit