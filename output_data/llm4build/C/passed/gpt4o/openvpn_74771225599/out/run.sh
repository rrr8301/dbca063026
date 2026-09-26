#!/bin/bash

# Clone the OpenVPN repository
git clone https://github.com/OpenVPN/openvpn.git
cd openvpn

# Run autoconf
autoreconf -fvi

# Run configure with specified options
./configure --with-crypto-library=openssl --enable-pkcs11 --enable-werror

# Build the project
make -j3

# Configure checks
echo 'RUN_SUDO="sudo -E"' > tests/t_server_null.rc

# Run tests
make -j3 check VERBOSE=1