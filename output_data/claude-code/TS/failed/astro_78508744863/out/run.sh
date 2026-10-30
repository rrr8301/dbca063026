#!/usr/bin/env bash
set -e

echo "=== Running test:integrations ==="
pnpm run test:integrations || {
  exit_code=$?
  echo "FINAL_STATUS = FAIL"
  exit $exit_code
}

echo "FINAL_STATUS = SUCCESS"
