#!/bin/bash
set -e

# Ensure Rust is in PATH
export PATH="/root/.cargo/bin:${PATH}"

# Run lints and tests using just
just lint test