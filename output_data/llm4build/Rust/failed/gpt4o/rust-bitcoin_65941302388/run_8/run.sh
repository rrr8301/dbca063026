#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define the actual repository URL
REPO_URL="github.com/actual-username/actual-repository.git"  # Corrected URL format

# Clone the repository using authentication
git clone https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@${REPO_URL} /app
cd /app

# Add architecture i386
dpkg --add-architecture i386

# Update package list and install i686 gcc
apt-get update -y
apt-get install -y gcc-multilib

# Source the Rust environment
source $HOME/.cargo/env || true

# Install Rust target for i686
rustup target add i686-unknown-linux-gnu

# Run tests
cargo test --target i686-unknown-linux-gnu