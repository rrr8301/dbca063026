#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Install project dependencies using UV
uv sync

# Run tests
make test-3.11