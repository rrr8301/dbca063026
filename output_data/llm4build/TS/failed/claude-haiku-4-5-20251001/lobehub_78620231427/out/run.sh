#!/bin/bash
set -e

# Export environment variables
export PACKAGES='@lobechat/file-loaders @lobechat/prompts @lobechat/model-runtime @lobechat/web-crawler @lobechat/electron-server-ipc @lobechat/utils @lobechat/python-interpreter @lobechat/context-engine @lobechat/agent-runtime @lobechat/conversation-flow @lobechat/ssrf-safe-fetch @lobechat/memory-user-memory @lobechat/types @lobechat/builtin-tool-lobe-agent model-bank'

# Install dependencies
echo "Installing dependencies with pnpm..."
pnpm install

# Run tests with coverage for each package
echo "Running tests with coverage..."
for package in $PACKAGES; do
    echo "::group::Testing $package"
    bun run --filter "$package" test:coverage
    echo "::endgroup::"
done

echo "All tests completed successfully!"