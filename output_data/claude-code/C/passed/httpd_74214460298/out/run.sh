#!/usr/bin/env bash
set -e

# Set environment variables for HTTP/2 test suite
export APR_VERSION=1.7.4
export APU_VERSION=1.6.3
export APU_CONFIG="--with-crypto"
export NO_TEST_FRAMEWORK=1
export TEST_INSTALL=1
export TEST_H2=1
export TEST_CORE=1
export TEST_PROXY=1
export MARGS="-j2"
export CFLAGS="-g"
export PHP_FPM=/usr/sbin/php-fpm8.1
export CONFIG="--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all"
export MFLAGS="-j2"

cd /app

# ASAN workaround (don't fail if sysctl fails in container)
sysctl vm.mmap_rnd_bits=28 2>/dev/null || true

# Fix IPv6 localhost issue in /etc/hosts
if grep ip6-localhost /etc/hosts 2>/dev/null; then
    grep -v "ip6-" /etc/hosts > /tmp/hosts.tmp && cat /tmp/hosts.tmp > /etc/hosts
fi

# Setup gdbinit
mkdir -p $HOME
echo "add-auto-load-safe-path /app/.gdbinit" >> $HOME/.gdbinit 2>/dev/null || true

# Run the setup script
bash ./test/travis_before_linux.sh

# Run the tests
bash ./test/travis_run_linux.sh
TEST_RESULT=$?

if [ $TEST_RESULT -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
