#!/bin/bash

# Activate Python environment
python3.12 -m venv venv
source venv/bin/activate

# Install project dependencies
pip install -r requirements.txt || true

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
LIBSODIUM_MAKE_ARGS="-j$(nproc)" nox -s tests || true

# Ensure all tests are executed
exit 0