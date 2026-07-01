#!/bin/bash

set -e

# Source Rust environment
. $HOME/.cargo/env

# Export PATH for build artifacts
export PATH=$PATH:$PWD/_build/dist/linux/core

# Code format check
echo "=== Running cargo fmt check ==="
cargo fmt --check

# Code clippy check
echo "=== Running make lint-all ==="
make lint-all

# Grammar test
echo "=== Running grammar test ==="
make && make test-grammar

# Runtime test
echo "=== Running runtime test ==="
make test-runtime

# Install KCL CLI
echo "=== Installing KCL CLI ==="
go install kcl-lang.io/cli/cmd/kcl@main
export PATH="$(go env GOPATH)/bin:${PATH}"

# Create Python virtual environment for test dependencies
echo "=== Setting up Python virtual environment ==="
python3 -m venv /tmp/test_venv
source /tmp/test_venv/bin/activate

# Unit test
echo "=== Running unit tests ==="
pip3 install --upgrade pytest pytest-html pytest-xdist ruamel.yaml
make test

# KCL Lib GLIBC 2.17 Build and Release
echo "=== Building KCL Lib with zigbuild ==="
pip3 install ziglang
cargo install --locked cargo-zigbuild
cargo clean
cargo zigbuild --target x86_64-unknown-linux-gnu.2.17 -r -p kcl-lib
cp -f target/x86_64-unknown-linux-gnu/release/libkcl.so _build/dist/linux/core
make release

# Read VERSION file
echo "=== Reading VERSION ==="
VERSION=$(cargo pkgid -p kcl-api | cut -d'@' -f2)
echo "VERSION=v${VERSION}"

# Rename artifact name with version
echo "=== Renaming artifact ==="
mv -f _build/dist/linux/kcl-latest-linux-amd64.tar.gz _build/dist/linux/kcl-v${VERSION}-linux-amd64.tar.gz

echo "=== Build and test completed successfully ==="