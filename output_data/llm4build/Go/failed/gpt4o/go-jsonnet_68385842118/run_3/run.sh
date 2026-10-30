#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Activate Python virtual environment
source /app/venv/bin/activate

# Install project dependencies
make install.dependencies

# Run tests
set +e  # Continue on errors
make test GOARCH="amd64" CGO_ENABLED="1" SKIP_PYTHON_BINDINGS_TESTS="0"