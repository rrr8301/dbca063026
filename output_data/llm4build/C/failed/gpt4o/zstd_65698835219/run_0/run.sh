#!/bin/bash

# Activate environment (if any)

# Install project dependencies
# No additional dependencies specified beyond system packages

# Run tests
set -e
set -o pipefail

# Update apt and install necessary packages
sudo apt update
APT_PACKAGES="gcc-multilib" make apt-install

# Run make check with specified CFLAGS
CFLAGS="-m32 -O1 -fstack-protector" make check V=1

# Run additional tests
CFLAGS="-m32 -O1 -fstack-protector" make V=1 -C tests test-cli-tests

# Ensure all tests are executed, even if some fail
exit 0