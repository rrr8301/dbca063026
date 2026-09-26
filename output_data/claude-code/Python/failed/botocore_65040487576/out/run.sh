#!/usr/bin/env bash
set -e

cd /app

echo "Installing botocore with CRT..."
python3.10 scripts/ci/install --extras crt

echo "Running CRT tests..."
python3.10 scripts/ci/run-crt-tests --with-cov --with-xdist

echo "FINAL_STATUS = SUCCESS"
