#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Run lints and tests
just lint test