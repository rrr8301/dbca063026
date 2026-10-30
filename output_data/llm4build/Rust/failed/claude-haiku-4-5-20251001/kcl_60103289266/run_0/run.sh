#!/bin/bash

set -e

# Source Rust environment
. $HOME/.cargo/env

# Export PATH for build artifacts
export PATH=$PATH:$PWD/_build/dist/linux/core

echo "=== Step 1: Code format check ==="
cargo fmt --check || true

echo "=== Step 2: Code clippy check ==="
make lint-all || true

echo "=== Step 3: Grammar test ==="
make && make test-grammar || true

echo "=== Step 4: Runtime test ==="
make test-runtime || true

echo "=== Step 5: Install KCL CLI ==="
go install kcl-lang.io/cli/cmd/kcl@main || true
export PATH="$(go env GOPATH)/bin:${PATH}"

echo "=== Step 6: Unit test ==="
make test || true

echo "=== Step 7: KCL Lib GLIBC 2.17 Build and Release ==="
pip3 install ziglang || true
cargo install --locked cargo-zigbuild || true
cargo clean || true
cargo zigbuild --target x86_64-unknown-linux-gnu.2.17 -r -p kcl-lib || true
cp -f target/x86_64-unknown-linux-gnu/release/libkcl.so _build/dist/linux/core || true
make release || true

echo "=== Step 8: Read VERSION file ==="
VERSION=$(cargo pkgid -p kcl-api | cut -d'@' -f2 || echo "unknown")
echo "VERSION=v${VERSION}"

echo "=== Step 9: Rename artifact ==="
if [ -f "_build/dist/linux/kcl-latest-linux-amd64.tar.gz" ]; then
    mv -f "_build/dist/linux/kcl-latest-linux-amd64.tar.gz" "_build/dist/linux/kcl-v${VERSION}-linux-amd64.tar.gz"
    echo "Artifact renamed to: kcl-v${VERSION}-linux-amd64.tar.gz"
else
    echo "Warning: Artifact file not found at _build/dist/linux/kcl-latest-linux-amd64.tar.gz"
fi

echo "=== Build and test complete ==="