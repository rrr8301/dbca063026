#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install Rust Bitcoin Maintainer Tools
# Assuming the setup-rbmt action installs some tools, replicate the installation here if possible
# Placeholder for actual installation commands
# e.g., cargo install <tool-name>

# Run tests
cargo rbmt test --toolchain stable --lock-file recent