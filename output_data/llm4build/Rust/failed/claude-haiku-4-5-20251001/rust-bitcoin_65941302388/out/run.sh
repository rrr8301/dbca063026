#!/bin/bash
set -e

# Add i386 architecture
dpkg --add-architecture i386

# Install i686 target
rustup target add i686-unknown-linux-gnu

# Run test on i686
cargo test --target i686-unknown-linux-gnu