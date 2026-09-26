#!/bin/bash
set -e

# Clone the repository
git clone https://github.com/rust-lang/rustlings.git /workspace/repo
cd /workspace/repo

# Run cargo test with RUST_BACKTRACE enabled
export RUST_BACKTRACE=1
export CARGO_TERM_COLOR=always

cargo test --workspace