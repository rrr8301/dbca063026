#!/usr/bin/env bash
set -e

cd /app

# Run the nox tests session with proper environment
LIBSODIUM_MAKE_ARGS="-j$(nproc)" nox -s tests

echo "FINAL_STATUS = SUCCESS"
