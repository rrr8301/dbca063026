#!/bin/bash
set -e

# Extract MSRV from Cargo.toml
msrv=$(grep 'rust-version.*1' Cargo.toml | sed 's/.*\.\([0-9]*\)\..*/\1/')
range=2

# Determine Rust version to install
rust_version="1.$((msrv+range)).0"

# Install Rust toolchain
export RUSTUP_USE_CURL=1
rustup set profile minimal
for attempt in 1 2 3 4 5; do
  if [ "$attempt" = "5" ]; then
    exit 1
  fi
  rustup update "$rust_version" --no-self-update && break
  sleep 5
done
rustup default "$rust_version"

# Set environment variables for Rust compilation
export CARGO_INCREMENTAL=0
export CARGO_PROFILE_DEV_DEBUG=0
export CARGO_PROFILE_TEST_DEBUG=0
export RUSTFLAGS="-D warnings $RUSTFLAGS"
export WIT_REQUIRE_SEMICOLONS=1

# Add WASM targets
rustup target add wasm32-wasip1 wasm32-unknown-unknown

# Fetch dependencies
cargo fetch --locked

# Display CPU information
lscpu

# Run tests with the exact command from the YAML
python3 ./ci/run-tests.py --locked \
  --exclude cranelift-tools \
  --package cranelift \
  --exclude cranelift-codegen \
  --exclude cranelift-assembler-x64 \
  --package cranelift-assembler-x64-meta \
  --exclude cranelift-srcgen \
  --exclude cranelift-bforest \
  --package cranelift-entity \
  --exclude cranelift-bitset \
  --exclude wasmtime-internal-core \
  --package cranelift-codegen-shared \
  --exclude cranelift-control \
  --exclude pulley-interpreter \
  --package pulley-macros \
  --exclude cranelift-codegen-meta \
  --exclude cranelift-isle \
  --package cranelift-frontend \
  --exclude cranelift-interpreter \
  --exclude cranelift-reader \
  --package cranelift-jit \
  --exclude cranelift-module \
  --exclude cranelift-native \
  --package wasmtime-internal-jit-icache-coherence \
  --exclude wasmtime-internal-unwinder \
  --exclude wasmtime-environ \
  --package wasmtime-internal-component-util \
  --exclude cranelift-object \
  --exclude cranelift-filetests \
  --package cranelift-assembler-x64-fuzz \
  --exclude isle-fuzz \
  --exclude islec \
  --package veri_engine \
  --exclude veri_ir \
  --exclude cranelift-serde \
  --package wasmtime-bench-api \
  --exclude wasmtime \
  --exclude wasmtime-internal-cache \
  --exclude wasmtime-internal-component-macro \
  --package wasmtime-internal-wit-bindgen \
  --exclude component-macro-test-helpers \
  --exclude wasmtime-internal-cranelift \
  --package wasmtime-internal-versioned-export-macros \
  --exclude wasmtime-internal-fiber \
  --exclude wasmtime-internal-jit-debug \
  --package wasmtime-internal-winch \
  --exclude winch-codegen \
  --exclude wasmtime-internal-wmemcheck \
  --package wasmtime-test-util \
  --exclude wasmtime-cli-flags \
  --exclude wasmtime-wasi \
  --exclude wasmtime-wasi-io \
  --package wiggle \
  --exclude wiggle-macro \
  --exclude wiggle-generate \
  --package wiggle-test \
  --exclude test-programs-artifacts \
  --exclude wasmtime-wasi-nn \
  --package wasmtime-c-api \
  --exclude wasmtime-c-api-impl \
  --exclude wasmtime-internal-c-api-macros \
  --package wasmtime-environ-fuzz \
  --exclude component-async-tests \
  --exclude test-programs \
  --package wasi-preview1-component-adapter \
  --exclude byte-array-literals \
  --exclude verify-component-adapter \
  --package wasmtime-wasi-tls-nativetls \
  --exclude wasmtime-wasi-tls \
  --exclude wasmtime-wasi-tls-openssl \
  --package wasmtime-internal-debugger \
  --exclude wizer-fuzz \
  --exclude wasmtime-wizer \
  --package regex-test \
  --exclude regex-bench \
  --exclude uap-bench \
  --package example-fib-debug-wasm \
  --exclude example-wasi-wasm \
  --exclude example-component-wasm \
  --exclude example-resource-component-wasm \
  --exclude min-platform-host \
  --package embedding \
  --exclude calculator \
  --exclude wasmtime-fuzz \
  --package cranelift-fuzzgen \
  --exclude pulley-interpreter-fuzz \
  --exclude wasmtime-fuzzing \
  --package wasm-spec-interpreter \
  --exclude wasmtime-wast \
  --exclude wasmtime-cli \
  --exclude wasi-common \
  --package wasmtime-internal-explorer \
  --exclude wasmtime-wasi-config \
  --exclude wasmtime-wasi-http \
  --package wasmtime-wasi-keyvalue \
  --exclude wasmtime-wasi-threads \
  --exclude wasmtime-test-macros