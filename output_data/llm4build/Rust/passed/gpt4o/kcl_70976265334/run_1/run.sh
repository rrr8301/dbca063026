#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Activate Rust environment
export PATH="/root/.cargo/bin:${PATH}"

# Install KCL CLI
go install kcl-lang.io/cli/cmd/kcl@main

# Export PATH for KCL CLI
export PATH=$PATH:$PWD/_build/dist/linux/core

# Run code format check
cargo fmt --check

# Run code clippy check
make lint-all

# Run grammar test
make && make test-grammar

# Run runtime test
make test-runtime

# Run unit test
make test

# KCL Lib GLIBC 2.17 Build and Release
pip3 install ziglang
cargo install --locked cargo-zigbuild
cargo clean
cargo zigbuild --target x86_64-unknown-linux-gnu.2.17 -r -p kcl-lib
cp -f target/x86_64-unknown-linux-gnu/release/libkcl.so _build/dist/linux/core
make release

# Read VERSION file
VERSION=$(cargo pkgid -p kcl-api | cut -d'@' -f2)
echo "VERSION=v${VERSION}"

# Rename artifact name with version
mv -f _build/dist/linux/kcl-latest-linux-amd64.tar.gz _build/dist/linux/kcl-${VERSION}-linux-amd64.tar.gz