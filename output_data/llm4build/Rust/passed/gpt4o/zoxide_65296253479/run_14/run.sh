#!/bin/bash

# Activate Rust environment
if [[ -f "${HOME}/.cargo/env" ]]; then
    source "${HOME}/.cargo/env"
else
    echo "Warning: ${HOME}/.cargo/env not found. Rust environment may not be fully activated."
fi

# Run lints and tests
just lint test