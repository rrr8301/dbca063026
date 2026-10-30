#!/bin/bash

# Activate any necessary environments (if applicable)

# Install project dependencies
./.github/workflows/install-ubuntu-dependencies.sh --full

# Run tests
test/ci-build.sh