#!/bin/bash

# Navigate to the working directory
cd /app/libraries/typescript

# Install dependencies
pnpm install --no-frozen-lockfile

# Build packages
pnpm build

# Verify CLI build artifact
test -f packages/cli/dist/index.cjs || { echo "::warning::dist/index.cjs missing after pnpm build, rebuilding CLI explicitly"; pnpm --filter @mcp-use/cli build; }

# Run CLI tests
MCP_USE_ANONYMIZED_TELEMETRY=false pnpm --filter @mcp-use/cli --if-present test