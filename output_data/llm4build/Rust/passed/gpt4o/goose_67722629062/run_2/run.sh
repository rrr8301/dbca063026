#!/bin/bash

# Start gnome-keyring-daemon
gnome-keyring-daemon --components=secrets --daemonize --unlock <<< 'foobar'

# Set environment variables
export CARGO_INCREMENTAL=0
export RUST_MIN_STACK=8388608

# Change to the crates directory
cd crates

# Run all tests
cargo test