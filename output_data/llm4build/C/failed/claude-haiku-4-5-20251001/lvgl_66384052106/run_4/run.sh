#!/bin/bash

set -e

# Set environment variables for 32-bit build
export NON_AMD64_BUILD=1

# Fix kernel mmap rnd bits (requires root, which is default in Docker)
# This may fail in some environments, so we ignore errors
sysctl -w vm.mmap_rnd_bits=28 2>/dev/null || true

# Activate virtual environment
source /workspace/venv/bin/activate

# Install prerequisites
echo "Installing prerequisites..."
# Remove sudo calls since we're running as root in Docker
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