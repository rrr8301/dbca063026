#!/usr/bin/env bash

cd /app

export BS="${BS:-cmake}"
export CRYPTO="${CRYPTO:-mbedtls}"
export MAKE_ARGS="${MAKE_ARGS:--j4}"
export SKIP_OPEN_FD_ERR_TEST="${SKIP_OPEN_FD_ERR_TEST:-1}"
export CTEST_OUTPUT_ON_FAILURE="${CTEST_OUTPUT_ON_FAILURE:-ON}"

echo "Running libarchive build with BS=$BS CRYPTO=$CRYPTO"

set -e
./build/ci/build.sh -a autogen
./build/ci/build.sh -a configure
./build/ci/build.sh -a build
set +e
./build/ci/build.sh -a test
TEST_RESULT=$?
set -e
./build/ci/build.sh -a install
./build/ci/build.sh -a artifact

if [ "${TEST_RESULT}" -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
  exit 0
else
  echo "FINAL_STATUS = FAIL"
  exit "${TEST_RESULT}"
fi
