#!/bin/bash

set -eu

cd /workspace

# Run the build and test using the cmake.py script
python3 .github/scripts/cmake.py \
  --os         Linux \
  --arch       x64 \
  --compiler   clang \
  --version    22 \
  --build-type Release \
  --target     asan/ubsan