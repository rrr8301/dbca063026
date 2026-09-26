#!/bin/bash
set -e

# Navigate to TypeScript library directory
cd /workspace/libraries/typescript

# Install dependencies
echo "Installing dependencies..."
pnpm install --no-frozen-lockfile

# Build packages
echo "Building packages..."
pnpm build

# Verify CLI build artifact
echo "Verifying CLI build artifact..."
if [ ! -f packages/cli/dist/index.cjs ]; then
    echo "Warning: dist/index.cjs missing after pnpm build, rebuilding CLI explicitly"
    pnpm --filter @mcp-use/cli build
fi

# Run CLI tests
echo "Running CLI tests..."
export MCP_USE_ANONYMIZED_TELEMETRY=false
pnpm --filter @mcp-use/cli --if-present test

echo "All tests completed successfully!"