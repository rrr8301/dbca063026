#!/bin/bash

# Ensure the script exits on any error
set -e

# Run build and test commands
cd /workspace
python3 .github/scripts/cmake.py \
  --os         Linux \
  --arch       x64 \
  --compiler   clang \
  --version    14 \
  --build-type Release \
  --target     asan/ubsan