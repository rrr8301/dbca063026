#!/bin/bash

# Run vendor script
./scripts/vendor.sh

# Build the project
make loadable static

# Sync tests with uv
uv sync --directory tests

# Run tests
make test-loadable