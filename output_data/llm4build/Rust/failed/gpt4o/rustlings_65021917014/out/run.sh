#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone . /app
cd /app

# Run cargo tests
export RUST_BACKTRACE=1
cargo test --workspace