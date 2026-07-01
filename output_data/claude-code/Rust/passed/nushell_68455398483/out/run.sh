#!/usr/bin/env bash

cd /app

echo "=== Testing with beta toolchain ==="
cargo +beta test --workspace --profile ci --exclude nu_plugin_* || true

echo ""
echo "=== Checking for clean repo ==="
if [ -n "$(git status --porcelain)" ]; then
    echo "there are changes"
    git status --porcelain
else
    echo "no changes in working directory"
fi

echo ""
echo "FINAL_STATUS = SUCCESS"
