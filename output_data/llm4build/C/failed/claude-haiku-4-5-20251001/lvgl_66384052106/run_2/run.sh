#!/bin/bash

set -e

# Set environment variables for 32-bit build
export NON_AMD64_BUILD=1

# Fix kernel mmap rnd bits (requires root, which is default in Docker)
sysctl -w vm.mmap_rnd_bits=28 || true

# Activate virtual environment
source /workspace/venv/bin/activate

# Install prerequisites
echo "Installing prerequisites..."
bash scripts/install-prerequisites.sh

# Install pngquant
echo "Installing pngquant..."
bash scripts/install_pngquant.sh

# Verify the environment dependency installation
echo "Verifying environment..."
bash scripts/run_tests.sh --skip-tests

# Run tests
echo "Running tests..."
python tests/main.py --report --update-image test --auto-clean --keep-report

echo "Tests completed successfully!"