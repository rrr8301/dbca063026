#!/bin/bash

# Activate Python environment
python3.12 -m venv venv
source venv/bin/activate

# Upgrade pip and install necessary Python packages
pip install --upgrade pip
pip install pypng lz4 kconfiglib

# Install project dependencies
./scripts/install-prerequisites.sh
./scripts/install_pngquant.sh

# Verify environment dependency installation
./scripts/run_tests.sh --skip-tests

# Set environment variables for 32-bit build
export NON_AMD64_BUILD=1

# Run tests
python tests/main.py --report --update-image test --auto-clean --keep-report