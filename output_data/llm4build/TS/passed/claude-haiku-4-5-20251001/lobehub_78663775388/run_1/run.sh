#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Install project dependencies
echo "Installing dependencies with pnpm..."
pnpm install

# Define packages to test
PACKAGES='@lobechat/file-loaders @lobechat/prompts @lobechat/model-runtime @lobechat/web-crawler @lobechat/electron-server-ipc @lobechat/utils @lobechat/python-interpreter @lobechat/context-engine @lobechat/agent-runtime @lobechat/conversation-flow @lobechat/ssrf-safe-fetch @lobechat/memory-user-memory @lobechat/types @lobechat/builtin-tool-lobe-agent model-bank'

# Test packages with coverage
echo "Running test coverage for packages..."
for package in $PACKAGES; do
  echo "::group::Testing $package"
  bun run --filter "$package" test:coverage
  echo "::endgroup::"
done

echo "All tests completed successfully!"