#!/bin/bash

set -e

echo "=== Node.js and pnpm versions ==="
node --version
npm --version
pnpm --version

echo "=== Loading environment from sample.env ==="
if [ -f sample.env ]; then
  # Load environment variables from sample.env (skip comments and empty lines)
  set -a
  source <(grep -v '^[[:space:]]*#' sample.env | grep -v '^$')
  set +a
  echo "Environment loaded from sample.env"
else
  echo "Warning: sample.env not found"
fi

echo "=== Installing dependencies ==="
pnpm install

echo "=== Installing Chrome for Puppeteer ==="
pnpm -F=curriculum install-puppeteer

echo "=== Running tests ==="
pnpm test

echo "=== Tests completed ==="