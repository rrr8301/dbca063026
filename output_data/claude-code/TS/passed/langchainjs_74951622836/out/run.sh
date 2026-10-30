#!/usr/bin/env bash
set -e

echo "Running tests for LangChain Core..."

pnpm run test:unit:ci --filter @langchain/core

if [ $? -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = FAIL"
  exit 1
fi
