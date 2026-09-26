#!/bin/bash

# Activate Python environment (if any virtual environment is used)
# source venv/bin/activate

# Install project dependencies
./.github/workflows/install-ubuntu-dependencies.sh --full

# Run the test script
test/ci-build.sh

# Ensure all tests are executed
set +e