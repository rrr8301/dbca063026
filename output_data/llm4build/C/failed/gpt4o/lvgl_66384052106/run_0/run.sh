#!/bin/bash

# Activate Python environment
python3.12 -m venv venv
source venv/bin/activate

# Install project dependencies
# Assuming dependencies are handled within the scripts
./scripts/install-prerequisites.sh
./scripts/install_pngquant.sh

# Verify environment dependency installation
./scripts/run_tests.sh --skip-tests

# Fix kernel mmap rnd bits
sudo sysctl vm.mmap_rnd_bits=28

# Set environment variables for 32-bit build
export NON_AMD64_BUILD=1

# Run tests
python tests/main.py --report --update-image test --auto-clean --keep-report