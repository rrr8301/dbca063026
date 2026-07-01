#!/bin/bash

# Clone the repository
git clone <actual-repository-url> /app
cd /app

# Add architecture i386
dpkg --add-architecture i386

# Update package list and install i686 gcc
apt-get update -y
apt-get install -y gcc-multilib

# Source the Rust environment
source $HOME/.cargo/env

# Install Rust target for i686
rustup target add i686-unknown-linux-gnu

# Run tests
cargo test --target i686-unknown-linux-gnu