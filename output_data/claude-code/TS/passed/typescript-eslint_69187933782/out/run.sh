#!/usr/bin/env bash
set -e

echo "Running unit tests for eslint-plugin with shard 4/4..."
pnpm exec nx test eslint-plugin -- --shard=4/4

echo "FINAL_STATUS = SUCCESS"
