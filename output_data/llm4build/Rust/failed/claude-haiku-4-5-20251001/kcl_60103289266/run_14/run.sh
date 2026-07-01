#!/bin/bash

set -e

# Export PATH for build artifacts
export PATH=$PATH:$PWD/_build/dist/linux/core

echo "=== Step 0: Resolve Cargo dependencies ==="
cargo fetch
# Update vergen_lib to resolve dependency conflict between vergen and vergen_gitcl
cargo update -p vergen_lib 2>&1 || true
cargo tree --depth 1 2>&1 | head -50

echo "=== Step 1: Code format check ==="
cargo fmt --check

echo "=== Step 2: Code clippy check ==="
make lint-all

echo "=== Step 3: Grammar test ==="
export PATH=$PATH:$PWD/_build/dist/linux/core
make && make test-grammar

echo "=== Step 4: Runtime test ==="
export PATH=$PATH:$PWD/_build/dist/linux/core
make test-runtime

echo "=== Step 5: Install KCL CLI ==="
go install kcl-lang.io/cli/cmd/kcl@main
export PATH="$(go env GOPATH)/bin:${PATH}"

echo "=== Step 6: Unit test ==="
export PATH=$PATH:$PWD/_build/dist/linux/core
make test

echo "=== Step 7: KCL Lib GLIBC 2.17 Build and Release ==="
pip3 install ziglang
cargo install --locked cargo-zigbuild
cargo clean
cargo zigbuild --target x86_64-unknown-linux-gnu.2.17 -r -p kcl-lib
cp -f target/x86_64-unknown-linux-gnu/release/libkcl.so _build/dist/linux/core
make release

echo "=== Step 8: Read VERSION file ==="
VERSION=$(cargo pkgid -p kcl-api | cut -d'@' -f2)
echo "VERSION=v${VERSION}"

echo "=== Step 9: Rename artifact ==="
if [ -f "_build/dist/linux/kcl-latest-linux-amd64.tar.gz" ]; then
    mv -f "_build/dist/linux/kcl-latest-linux-amd64.tar.gz" "_build/dist/linux/kcl-v${VERSION}-linux-amd64.tar.gz"
    echo "Artifact renamed to: kcl-v${VERSION}-linux-amd64.tar.gz"
else
    echo "Error: Artifact file not found at _build/dist/linux/kcl-latest-linux-amd64.tar.gz"
    exit 1
fi

echo "=== Build and test complete ==="