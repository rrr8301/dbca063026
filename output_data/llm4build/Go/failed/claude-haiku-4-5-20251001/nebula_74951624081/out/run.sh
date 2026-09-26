#!/bin/sh
set -e

# Navigate to workspace
cd /workspace

# Build
make bin-pkcs11

# Test
make test-pkcs11