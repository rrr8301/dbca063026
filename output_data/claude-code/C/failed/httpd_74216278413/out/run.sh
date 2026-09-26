#!/usr/bin/env bash
set -ex

cd /app

# Set environment variables from job matrix
export MARGS="-j2"
export CFLAGS="-g"
export APR_VERSION=1.7.4
export APU_VERSION=1.6.3
export APU_CONFIG="--with-crypto"
export NO_TEST_FRAMEWORK=1
export TEST_INSTALL=1
export TEST_H2=1
export TEST_CORE=1
export TEST_PROXY=1
export CONFIG="--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all"

# Generate job ID
export JOBID=$(echo "OS=Ubuntu ${{ matrix.notest-cflags }} APR_VERSION=$APR_VERSION APU_VERSION=$APU_VERSION APU_CONFIG=$APU_CONFIG NO_TEST_FRAMEWORK=$NO_TEST_FRAMEWORK TEST_INSTALL=$TEST_INSTALL TEST_H2=$TEST_H2 TEST_CORE=$TEST_CORE TEST_PROXY=$TEST_PROXY CONFIG=$CONFIG" | md5sum - | sed 's/ .*//')

# Run before_linux script
bash test/travis_before_linux.sh

# Run the actual build and tests
set +e
bash test/travis_run_linux.sh
TEST_RESULT=$?
set -e

if [ $TEST_RESULT -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL (exit code: $TEST_RESULT)"
fi

exit $TEST_RESULT
