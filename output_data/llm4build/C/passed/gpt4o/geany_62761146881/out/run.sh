#!/bin/bash

# Clone the repository (simulating actions/checkout)
# Assuming the repository URL is known and accessible
# git clone <repository-url> .

# Install project dependencies
# No additional dependencies specified beyond system packages

# Configure the build with Meson
meson _build

# Build with Ninja
ninja -C _build

# Run tests with Ninja
ninja -C _build test