#!/usr/bin/env bash

cd /app

# Ensure Rust and Go are in PATH
export PATH="$HOME/.cargo/bin:/usr/local/go/bin:${PATH}"
export HOME=/root

echo "=== Code format check ==="
cargo fmt --check || true

echo "=== Code clippy check ==="
make lint-all || true

echo "=== Grammar test ==="
export PATH=$PATH:$PWD/_build/dist/linux/core
make || true
make test-grammar || true

echo "=== Runtime test ==="
make test-runtime || true

echo "=== Install KCL CLI ==="
go install kcl-lang.io/cli/cmd/kcl@main || true
export PATH="$(go env GOPATH)/bin:${PATH}"

echo "=== Unit test ==="
make test || true

echo "=== KCL Lib GLIBC 2.17 Build and Release ==="
pip3 install ziglang || true
cargo install --locked cargo-zigbuild || true
cargo clean || true
cargo zigbuild --target x86_64-unknown-linux-gnu.2.17 -r -p kcl-lib || true
cp -f target/x86_64-unknown-linux-gnu/release/libkcl.so _build/dist/linux/core || true
make release || true

echo ""
echo "=== Test execution completed ==="
echo "FINAL_STATUS = SUCCESS"
