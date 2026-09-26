#!/bin/bash

set -e

# Clone the repository (assuming it's passed as an argument or we're already in the repo)
# If running in the repo directory, skip cloning
if [ ! -f "sys/install.sh" ]; then
    echo "Repository not found. Cloning radare2..."
    git clone https://github.com/radareorg/radare2 /workspace/radare2
    cd /workspace/radare2
else
    cd /workspace
fi

echo "=== Building Radare2 ==="

# Upgrade pip
python3 -m pip install --upgrade pip

# Install Python dependencies
pip3 install --user r2pipe wheel

# Set compiler flags
export CFLAGS="-O2 -Wno-unused-result"

# Run the installation script
bash sys/install.sh

echo "=== Running Tests ==="

# Set library path for runtime
export LD_LIBRARY_PATH=/usr/local/lib

# Run tests (continue even if tests fail to ensure all tests are executed)
make tests || TEST_FAILED=1

# Exit with appropriate code
if [ "$TEST_FAILED" = "1" ]; then
    echo "Some tests failed, but test suite execution completed."
    exit 1
fi

echo "=== All tests passed ==="
exit 0