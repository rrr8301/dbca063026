#!/bin/bash

# Clone mbed TLS if not cached
if [ ! -d "/opt/mbedtls4" ]; then
    git clone --branch v4.1.0 --recursive https://github.com/Mbed-TLS/mbedtls.git mbedtls
    cd mbedtls
    cmake -B build -DCMAKE_INSTALL_PREFIX=/opt/mbedtls4
    cmake --build build
    cmake --install build
    cd ..
fi

# Set PKG_CONFIG_PATH to find mbed TLS
export PKG_CONFIG_PATH=/opt/mbedtls4/lib/pkgconfig

# Clone OpenVPN repository
git clone https://github.com/OpenVPN/openvpn.git
cd openvpn

# Run autoconf
autoreconf -fvi

# Configure with mbed TLS
./configure --with-crypto-library=mbedtls --enable-werror

# Build OpenVPN
make -j3

# Ensure the build uses mbed TLS v4.1.0
./src/openvpn/openvpn --version
./src/openvpn/openvpn --version | grep -q "library versions: mbed TLS 4."

# Configure checks
echo 'RUN_SUDO="sudo -E"' >tests/t_server_null.rc

# Run make check
make -j3 check VERBOSE=1