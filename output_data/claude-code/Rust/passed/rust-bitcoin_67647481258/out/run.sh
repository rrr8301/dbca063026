#!/usr/bin/env bash
set -e

cd /app

cargo rbmt test --toolchain stable --lock-file recent

echo "FINAL_STATUS = SUCCESS"
