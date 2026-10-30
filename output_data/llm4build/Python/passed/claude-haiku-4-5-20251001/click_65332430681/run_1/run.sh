#!/bin/bash

set -e

# Print commands for debugging
set -x

# Navigate to workspace
cd /workspace

# Ensure uv is available
export PATH="/root/.cargo/bin:$PATH"

# Run the locked tox tests for Python 3.11
# The --locked flag ensures uv uses the exact versions from uv.lock
uv run --locked tox run -e py3.11

# Exit with success if all tests passed
exit 0