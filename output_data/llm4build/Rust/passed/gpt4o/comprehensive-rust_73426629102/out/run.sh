#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone . /app
cd /app

# Update Rust
rustup update

# Build Rust code
cargo build

# Test Rust code
cargo test