#!/usr/bin/env bash
set -e

cmake -S . -B build \
    -DCXX_NEXT=ON \
    -DCI_MODE=1 -DBUILD_STATIC_LIBS=0 -DCMAKE_BUILD_TYPE=Release \
    -DREQUIRE_CRYPTO_OPENSSL=1 -DREQUIRE_CRYPTO_GNUTLS=1 \
    -DENABLE_QTC=1
cmake --build build --verbose -j$(nproc) -- -k
cd build
ctest --verbose

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS=$FINAL_STATUS"
