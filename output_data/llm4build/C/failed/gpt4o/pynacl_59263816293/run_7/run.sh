#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Activate Python environment
python3.12 -m venv venv
source venv/bin/activate

# Check if requirements.txt exists
if [ ! -f /app/requirements.txt ]; then
    echo "Error: /app/requirements.txt not found."
    exit 1
fi

# Install project dependencies
pip install -r /app/requirements.txt

# Install libsodium
wget --timeout=60 https://download.libsodium.org/libsodium/releases/LATEST.tar.gz || \
wget --timeout=60 https://download.libsodium.org/libsodium/releases/LATEST.tar.gz
tar zxvf LATEST.tar.gz
cd libsodium-*
./configure --enable-minimal
make
make check
sudo make install
sudo ldconfig
cd ..

# Run tests
LIBSODIUM_MAKE_ARGS="-j$(nproc)" nox -s tests

# Ensure all tests are executed
exit 0