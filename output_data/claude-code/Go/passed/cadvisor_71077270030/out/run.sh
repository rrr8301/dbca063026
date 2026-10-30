#!/usr/bin/env bash

set -ex

cd /app

# Run presubmit checks
echo ">> Running presubmit checks"
source build/config/plain.sh
if [[ "${BUILD_PACKAGES}" != "" ]]; then
  apt-get update
  apt-get install -y ${BUILD_PACKAGES}
fi
make -e presubmit

# Run tests
echo ">> Running tests"
source build/config/plain.sh
make test

echo "FINAL_STATUS = SUCCESS"
