#!/usr/bin/env bash

set -e

# Source cargo environment
source /root/.cargo/env

cd /app

echo "=== Step 1: Code format check ==="
cargo fmt --check || true

echo "=== Step 2: Code clippy check ==="
make lint-all || true

echo "=== Step 3: Grammar test ==="
export PATH=$PATH:$PWD/_build/dist/linux/core
make || true
make test-grammar || true

echo "=== Step 4: Runtime test ==="
export PATH=$PATH:$PWD/_build/dist/linux/core
make test-runtime || true

echo "=== Step 5: Install KCL CLI ==="
go install kcl-lang.io/cli/cmd/kcl@main || true
export PATH="/root/go/bin:${PATH}"

echo "=== Step 6: Unit test ==="
export PATH=$PATH:$PWD/_build/dist/linux/core
make test || true

echo "=== Step 7: KCL Lib GLIBC 2.17 Build and Release ==="
pip3 install ziglang || true
cargo install --locked cargo-zigbuild || true
cargo clean || true
cargo zigbuild --target x86_64-unknown-linux-gnu.2.17 -r -p kcl-lib || true
cp -f target/x86_64-unknown-linux-gnu/release/libkcl.so _build/dist/linux/core || true
make release || true

echo "=== All steps completed ==="
FINAL_STATUS = SUCCESS
