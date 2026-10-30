#!/bin/bash
set -e

# Navigate to the TypeScript libraries directory
cd /workspace/libraries/typescript

# Install dependencies
pnpm install --no-frozen-lockfile

# Build packages
pnpm build

# Run mcp-use Unit Tests
export MCP_USE_ANONYMIZED_TELEMETRY=false
pnpm --filter mcp-use --if-present test:unit