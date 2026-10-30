#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone . /app

# Change to the app directory
cd /app

# Install Rust dependencies
cargo build --release

# Run tests
cargo test --workspace