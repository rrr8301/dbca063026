#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
make bin-pkcs11

# Run tests
make test-pkcs11