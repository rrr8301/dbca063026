#!/usr/bin/env bash
set -e

cd /app

export LIBSODIUM_MAKE_ARGS="-j$(nproc)"
export PYTHONUNBUFFERED=1

python3.12 -m nox -s tests

echo "FINAL_STATUS = SUCCESS"
