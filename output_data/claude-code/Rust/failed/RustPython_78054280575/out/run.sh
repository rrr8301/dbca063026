#!/usr/bin/env bash
set -e

cd /app

echo "Running rust tests..."
cargo test --workspace --exclude rustpython-capi \
  --exclude rustpython_wasm \
  --exclude rustpython-compiler-source \
  --exclude rustpython-venvlauncher \
  --features threading \
  --no-default-features \
  --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env

echo "FINAL_STATUS = SUCCESS"
