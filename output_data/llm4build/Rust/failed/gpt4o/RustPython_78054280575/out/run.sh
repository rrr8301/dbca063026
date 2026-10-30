#!/bin/bash

# Source Rust environment
source "$HOME/.cargo/env"

# Run Rust tests
cargo test --workspace --exclude rustpython-capi --exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher --features threading --no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls,host_env