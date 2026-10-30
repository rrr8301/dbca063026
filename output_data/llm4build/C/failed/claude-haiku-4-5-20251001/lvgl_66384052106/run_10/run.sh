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
# Create a temporary script with --user flags removed and proper pip install handling
sed -e 's/--user//g' \
    -e 's/pip install  /pip install /g' \
    -e 's/python -m pip install  /python -m pip install /g' \
    -e 's/python3 -m pip install  /python3 -m pip install /g' \
    scripts/install-prerequisites.sh > /tmp/install-prerequisites-fixed.sh
chmod +x /tmp/install-prerequisites-fixed.sh
bash /tmp/install-prerequisites-fixed.sh || true

# Install pngquant
echo "Installing pngquant..."
# Create a temporary script with --user flags removed and proper pip install handling
sed -e 's/--user//g' \
    -e 's/pip install  /pip install /g' \
    -e 's/python -m pip install  /python -m pip install /g' \
    -e 's/python3 -m pip install  /python3 -m pip install /g' \
    scripts/install_pngquant.sh > /tmp/install_pngquant-fixed.sh
chmod +x /tmp/install_pngquant-fixed.sh
bash /tmp/install_pngquant-fixed.sh || true

# Verify the environment dependency installation
echo "Verifying environment..."
bash scripts/run_tests.sh --skip-tests || true

# Run tests
echo "Running tests..."
python tests/main.py --report --update-image test --auto-clean --keep-report

echo "Tests completed successfully!"