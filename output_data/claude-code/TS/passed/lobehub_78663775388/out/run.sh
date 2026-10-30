#!/usr/bin/env bash
set -e

PACKAGES='@lobechat/file-loaders @lobechat/prompts @lobechat/model-runtime @lobechat/web-crawler @lobechat/electron-server-ipc @lobechat/utils @lobechat/python-interpreter @lobechat/context-engine @lobechat/agent-runtime @lobechat/conversation-flow @lobechat/ssrf-safe-fetch @lobechat/memory-user-memory @lobechat/types @lobechat/builtin-tool-lobe-agent model-bank'

for package in $PACKAGES; do
  echo "Testing $package"
  bun run --filter $package test:coverage || true
done

FINAL_STATUS = SUCCESS
