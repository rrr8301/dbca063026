#!/bin/bash

# Start gnome-keyring-daemon
gnome-keyring-daemon --components=secrets --daemonize --unlock <<< 'foobar'

# Set environment variables
export CARGO_INCREMENTAL=0
export RUST_MIN_STACK=8388608

# Set LIBCLANG_PATH to the directory containing libclang
export LIBCLANG_PATH=$(llvm-config --libdir)

# Navigate to the crates directory
cd crates

# Build and test the Rust project
cargo test  # Run all tests without skipping