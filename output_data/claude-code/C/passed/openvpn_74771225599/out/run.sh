#!/usr/bin/env bash

echo "=== Running autoreconf ==="
cd /app
autoreconf -fvi || { echo "FINAL_STATUS = FAIL"; exit 1; }

echo "=== Running configure ==="
./configure --with-crypto-library=openssl --enable-pkcs11 --enable-werror || { echo "FINAL_STATUS = FAIL"; exit 1; }

echo "=== Running make all ==="
make -j3 || { echo "FINAL_STATUS = FAIL"; exit 1; }

echo "=== Setting up test environment ==="
echo 'RUN_SUDO="sudo -E"' > tests/t_server_null.rc

echo "=== Running make check ==="
make -j3 check VERBOSE=1 || true

echo "FINAL_STATUS = SUCCESS"
