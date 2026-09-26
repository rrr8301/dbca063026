#!/usr/bin/env bash
set -e

cd /app/libraries/typescript

# Run mcp-use Unit Tests
export MCP_USE_ANONYMIZED_TELEMETRY=false
pnpm --filter mcp-use --if-present test:unit

echo "FINAL_STATUS = SUCCESS"
