#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies
just install

# Run tests
set +e  # Continue on errors
just test-all