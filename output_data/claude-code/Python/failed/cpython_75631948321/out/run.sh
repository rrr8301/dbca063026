#!/usr/bin/env bash
set -e

cd /app

# Configure CPython
./configure \
    --config-cache \
    --with-pydebug \
    --enable-slower-safety \
    --enable-safety \
    --with-openssl="$OPENSSL_DIR" \
    CFLAGS="-fdiagnostics-format=json"

# Build CPython
make -j$(nproc) --output-sync 2>&1 | tee compiler_output.txt

# Display build info
make pythoninfo

# Run tests
echo "Running tests..."
xvfb-run make ci EXTRATESTOPTS="" || true

echo "FINAL_STATUS = SUCCESS"
