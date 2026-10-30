#!/bin/bash

# Activate nvm and use Node.js 20
export NVM_DIR="/root/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use 20

# Change to the working directory
cd libraries/typescript

# Install project dependencies
pnpm install --no-frozen-lockfile

# Build packages
pnpm build

# Run unit tests for mcp-use
MCP_USE_ANONYMIZED_TELEMETRY=false pnpm --filter mcp-use --if-present test:unit