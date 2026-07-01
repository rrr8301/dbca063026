#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Run tests using the exact command from the YAML
just test-all