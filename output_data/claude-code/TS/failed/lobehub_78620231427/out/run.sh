#!/usr/bin/env bash

set -e

cd /app

PACKAGES='@lobechat/file-loaders @lobechat/prompts @lobechat/model-runtime @lobechat/web-crawler @lobechat/electron-server-ipc @lobechat/utils @lobechat/python-interpreter @lobechat/context-engine @lobechat/agent-runtime @lobechat/conversation-flow @lobechat/ssrf-safe-fetch @lobechat/memory-user-memory @lobechat/types @lobechat/builtin-tool-lobe-agent model-bank'

TEST_FAILED=0

for package in $PACKAGES; do
  echo "::group::Testing $package"
  if ! bun run --filter "$package" test:coverage; then
    TEST_FAILED=1
  fi
  echo "::endgroup::"
done

if [ $TEST_FAILED -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = FAIL"
  exit 1
fi
