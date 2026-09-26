#!/bin/bash

# Activate environment variables if needed
# (No specific environment activation needed for this job)

# Install project dependencies
# (No additional project-specific dependencies mentioned)

# Run build and test commands
cd /workspace
python3 .github/scripts/cmake.py \
  --os         ubuntu-24.04 \
  --arch       x64 \
  --compiler   clang \
  --version    22 \
  --build-type Release \
  --target     asan/ubsan