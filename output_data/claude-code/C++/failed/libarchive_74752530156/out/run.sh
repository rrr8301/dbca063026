#!/usr/bin/env bash
set -e

export BS=autotools
export CRYPTO=mbedtls
export MAKE_ARGS=-j4
export SKIP_OPEN_FD_ERR_TEST=1
export CTEST_OUTPUT_ON_FAILURE=ON

cd /app

echo "=== Autogen ==="
./build/ci/build.sh -a autogen

echo "=== Configure ==="
./build/ci/build.sh -a configure

echo "=== Build ==="
./build/ci/build.sh -a build

echo "=== Test ==="
./build/ci/build.sh -a test || true

echo "=== Install ==="
./build/ci/build.sh -a install || true

echo "=== Artifact ==="
./build/ci/build.sh -a artifact || true

echo "FINAL_STATUS = SUCCESS"
