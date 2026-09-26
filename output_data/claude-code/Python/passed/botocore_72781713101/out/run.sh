#!/usr/bin/env bash
set -e

cd /app

python scripts/ci/run-tests --with-cov --with-xdist unit/ functional/

echo "FINAL_STATUS = SUCCESS"
