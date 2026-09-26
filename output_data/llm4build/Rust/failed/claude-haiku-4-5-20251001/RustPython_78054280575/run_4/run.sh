#!/bin/bash
set -e

# Activate Rust environment
. $HOME/.cargo/env

# Set environment variables for the test run
export CARGO_ARGS="--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls,host_env"
export WORKSPACE_EXCLUDES="--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher"
export INSTA_WORKSPACE_ROOT="/workspace"

# Run rust tests
cd /workspace
cargo test --workspace --exclude rustpython-capi $WORKSPACE_EXCLUDES --features threading $CARGO_ARGS