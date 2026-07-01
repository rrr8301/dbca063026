#!/bin/bash

# Ensure Rust environment is activated
source $HOME/.cargo/env

# Run tests
cargo run -p ci -- test