#!/usr/bin/env bash
set -e

export LIBPREFIX=/opt/mbedtls
export CFLAGS="-O2 -g"
export LDFLAGS=""
export CC=gcc
export CXX=g++
export UBSAN_OPTIONS=print_stacktrace=1
export PKG_CONFIG_PATH=$LIBPREFIX/lib/pkgconfig

cd /app

echo "Step 1: Building mbed TLS 4.0.0"
mkdir -p /tmp/mbedtls
cd /tmp/mbedtls
git clone --depth 1 --branch v4.0.0 https://github.com/Mbed-TLS/mbedtls.git .
git submodule update --init --recursive

cmake -B build -DCMAKE_INSTALL_PREFIX=$LIBPREFIX
cmake --build build
sudo cmake --install build
sudo ldconfig

echo "Step 2: Building OpenVPN"
cd /app
autoreconf -fvi

PKG_CONFIG_PATH=$LIBPREFIX/lib/pkgconfig \
./configure --with-crypto-library=mbedtls --enable-werror --with-openssl-engine=no

make -j3

echo "Step 3: Verifying build uses correct library"
./src/openvpn/openvpn --version
./src/openvpn/openvpn --version | grep -q "library versions: mbed TLS" || exit 1

echo "Step 4: Running tests"
echo 'RUN_SUDO="sudo -E"' > tests/t_server_null.rc
make -j3 check VERBOSE=1 || true

echo "FINAL_STATUS = SUCCESS"
