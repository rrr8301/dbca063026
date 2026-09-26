#!/bin/bash

# Run vendor script
./scripts/vendor.sh

# Build loadable static
make loadable static

# Sync tests with uv
uv sync --directory tests

# Run tests
make test-loadable