#!/usr/bin/env bash
set -e

export PATH=$HOME/.cargo/bin:$PATH
export CARGO_TERM_COLOR=always
export CLICOLOR=1
export GIX_TEST_IGNORE_ARCHIVES=1

cd /app

echo "=== Running just ci-test ==="
just ci-test

echo ""
echo "FINAL_STATUS = SUCCESS"
