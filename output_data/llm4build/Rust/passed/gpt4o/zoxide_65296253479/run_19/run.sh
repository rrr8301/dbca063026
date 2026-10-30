#!/bin/bash

# Activate Rust environment
if [[ -f "${HOME}/.cargo/env" ]]; then
    # shellcheck source=/dev/null
    source "${HOME}/.cargo/env"
else
    echo "Warning: ${HOME}/.cargo/env not found. Rust environment may not be fully activated."
fi

# Run lints and tests
set -e  # Exit immediately if a command exits with a non-zero status
just lint test || {
    echo "Linting or tests failed. Please check the output above for details."
    exit 1
}