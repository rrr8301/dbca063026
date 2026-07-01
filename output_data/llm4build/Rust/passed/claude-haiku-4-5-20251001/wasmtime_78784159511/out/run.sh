#!/bin/bash
set -e

# Install Rust toolchain
echo "Installing Rust toolchain..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal
source "$HOME/.cargo/env"

# Extract MSRV from Cargo.toml
msrv=$(grep 'rust-version.*1' Cargo.toml | sed 's/.*\.\([0-9]*\)\..*/\1/')
range=2
version="1.$((msrv+range)).0"

echo "Installing Rust version: $version"
for attempt in 1 2 3 4 5; do
  if [ "$attempt" = "5" ]; then
    echo "Failed to install Rust after 5 attempts"
    exit 1
  fi
  if rustup update "$version" --no-self-update; then
    break
  fi
  sleep 5
done

rustup default "$version"

# Add WASM targets
echo "Adding WASM targets..."
rustup target add wasm32-wasip1 wasm32-unknown-unknown wasm32-wasip2

# Fetch dependencies with locked versions
echo "Fetching Cargo dependencies..."
cargo fetch --locked

# Display CPU information
echo "CPU Information:"
lscpu

# Install VTune (Intel VTune Profiler)
echo "Installing VTune..."
cd /tmp
wget -q https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB 2>/dev/null || true
echo "deb https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list >/dev/null 2>&1 || true
sudo apt-get update >/dev/null 2>&1 || true
sudo apt-get install -y intel-oneapi-vtune >/dev/null 2>&1 || true
cd /workspace

# Run the comprehensive test suite
echo "Running test suite..."
python3 ./ci/run-tests.py --locked \
  --package cranelift-tools --exclude cranelift --exclude cranelift-codegen \
  --package cranelift-assembler-x64 --exclude cranelift-assembler-x64-meta --exclude cranelift-srcgen \
  --package cranelift-bforest --exclude cranelift-entity --exclude cranelift-bitset \
  --package wasmtime-internal-core --exclude cranelift-codegen-shared --exclude cranelift-control \
  --package pulley-interpreter --exclude pulley-macros --exclude cranelift-codegen-meta \
  --package cranelift-isle --exclude cranelift-frontend --exclude cranelift-interpreter \
  --package cranelift-reader --exclude cranelift-jit --exclude cranelift-module \
  --package cranelift-native --exclude wasmtime-internal-jit-icache-coherence --exclude wasmtime-internal-unwinder \
  --package wasmtime-environ --exclude wasmtime-internal-component-util --exclude cranelift-object \
  --package cranelift-filetests --exclude cranelift-assembler-x64-fuzz --exclude isle-fuzz \
  --package islec --exclude veri_engine --exclude veri_ir \
  --package cranelift-serde --exclude wasmtime-bench-api --exclude wasmtime --exclude wasmtime-internal-cache \
  --package wasmtime-internal-component-macro --exclude wasmtime-internal-wit-bindgen --exclude component-macro-test-helpers \
  --package wasmtime-internal-cranelift --exclude wasmtime-internal-versioned-export-macros --exclude wasmtime-internal-fiber \
  --package wasmtime-internal-jit-debug --exclude wasmtime-internal-winch --exclude winch-codegen \
  --package wasmtime-internal-wmemcheck --exclude wasmtime-test-util --exclude wasmtime-cli-flags --exclude wasmtime-wasi \
  --package wasmtime-wasi-io --exclude wiggle --exclude wiggle-macro \
  --package wiggle-generate --exclude wiggle-test --exclude test-programs-artifacts \
  --package wasmtime-wasi-nn --exclude wasmtime-c-api --exclude wasmtime-c-api-impl \
  --package wasmtime-internal-c-api-macros --exclude wasmtime-wasi-http --exclude wasmtime-environ-fuzz \
  --package component-async-tests --exclude test-programs --exclude wasi-preview1-component-adapter \
  --package byte-array-literals --exclude verify-component-adapter --exclude wasmtime-internal-debugger \
  --package wasmtime-internal-gdbstub-component --exclude wasmtime-internal-gdbstub-component-artifact --exclude wizer-fuzz \
  --package wasmtime-wizer --exclude regex-bench --exclude uap-bench \
  --package example-fib-debug-wasm --exclude example-wasi-wasm --exclude example-tokio-wasm \
  --package example-component-wasm --exclude example-resource-component-wasm --exclude min-platform-host \
  --package embedding --exclude calculator --exclude wasmtime-fuzz \
  --package cranelift-fuzzgen --exclude pulley-interpreter-fuzz --exclude wasmtime-fuzzing \
  --package wasm-spec-interpreter --exclude wasmtime-wast --exclude wasmtime-cli --exclude wasi-common \
  --package wasmtime-internal-explorer --exclude wasmtime-wasi-config --exclude wasmtime-wasi-keyvalue \
  --package wasmtime-wasi-threads --exclude wasmtime-wasi-tls --exclude wasmtime-test-macros

echo "Test suite completed successfully!"