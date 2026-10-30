#!/usr/bin/env bash
set -e

cd /app

# Source Rust environment
. $HOME/.cargo/env

echo "=== Running Bazel Tests ==="
bazel test //... || TEST_RESULT=$?

if [ "$TEST_RESULT" != "0" ] && [ -n "$TEST_RESULT" ]; then
    echo "FINAL_STATUS = FAIL"
    exit 1
fi

echo "=== Running Rust CLI Smoke Test ==="
bazel build \
    --compilation_mode=opt \
    --remote_download_outputs=all \
    //crates/formatjs_cli 2>&1 || SMOKE_RESULT=$?

if [ "$SMOKE_RESULT" != "0" ] && [ -n "$SMOKE_RESULT" ]; then
    echo "FINAL_STATUS = FAIL"
    exit 1
fi

BINARY_PATH=bazel-bin/crates/formatjs_cli/formatjs_cli
$BINARY_PATH --version || true
$BINARY_PATH --help || true

echo "FINAL_STATUS = SUCCESS"
