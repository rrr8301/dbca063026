#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Activate Rust environment
source $HOME/.cargo/env

# Navigate to the directory containing the go.mod file
cd /app  # Assuming /app is the directory where go.mod is located

# Install Go KCL CLI
# Ensure the Go version is compatible with the go.mod requirements
go mod tidy  # Ensure go.mod is up-to-date
go install kcl-lang.io/cli/cmd/kcl@main || {
    echo "Failed to install KCL CLI. Please check the Go version compatibility."
    exit 1
}

# Export paths
export PATH=$PATH:$PWD/_build/dist/linux/core

# Run code format check
cargo fmt --check

# Run clippy check
make lint-all

# Run grammar test
make && make test-grammar

# Run runtime test
make test-runtime

# Run unit tests
make test

# Build and release KCL Lib GLIBC 2.17
pip3 install --break-system-packages ziglang
cargo install --locked cargo-zigbuild
cargo clean
cargo zigbuild --target x86_64-unknown-linux-gnu.2.17 -r -p kcl-lib

# Ensure the target directory exists before copying
if [ -f target/x86_64-unknown-linux-gnu/release/libkcl.so ]; then
    cp -f target/x86_64-unknown-linux-gnu/release/libkcl.so _build/dist/linux/core
else
    echo "Error: libkcl.so not found"
    exit 1
fi

make release

# Read VERSION file
VERSION=$(cargo pkgid -p kcl-api | cut -d'@' -f2)
echo "VERSION=v${VERSION}"

# Rename artifact
mv -f _build/dist/linux/kcl-latest-linux-amd64.tar.gz _build/dist/linux/kcl-${VERSION}-linux-amd64.tar.gz