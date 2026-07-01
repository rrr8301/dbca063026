#!/bin/bash

# Clone the repository
git clone <repository-url> /app
cd /app

# Add architecture i386
sudo dpkg --add-architecture i386

# Update package list and install i686 gcc
sudo apt-get update -y
sudo apt-get install -y gcc-multilib

# Install Rust target for i686
rustup target add i686-unknown-linux-gnu

# Run tests
cargo test --target i686-unknown-linux-gnu