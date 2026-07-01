#!/bin/bash

# Navigate to the application directory
cd /app

# Build the Rust project
cargo build --release

# Run the Rust application
./target/release/my_rust_app