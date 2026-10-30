#!/usr/bin/env bash
set -e

cd /app/libraries/typescript

export MCP_USE_ANONYMIZED_TELEMETRY=false

echo "=== Build Packages ==="
pnpm build

echo "=== Verify CLI build artifact ==="
test -f packages/cli/dist/index.cjs || { echo "::warning::dist/index.cjs missing after pnpm build, rebuilding CLI explicitly"; pnpm --filter @mcp-use/cli build; }

echo "=== Run CLI Tests ==="
pnpm --filter @mcp-use/cli --if-present test

echo "FINAL_STATUS = SUCCESS"
