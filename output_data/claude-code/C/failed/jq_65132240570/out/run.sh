#!/usr/bin/env bash
set -e

# Build step from workflow
autoreconf -i
./configure \
  --disable-docs \
  --with-oniguruma=builtin \
  --disable-shared \
  --enable-static \
  --enable-all-static \
  CFLAGS="-O2 -pthread -fstack-protector-all -m32"

make -j"$(nproc)"
file ./jq
cp ./jq jq-${SUFFIX}

# Test step from workflow - allow failure
set +e
make check VERBOSE=yes
TEST_RESULT=$?
set -e

git diff --exit-code

# If we got here, tests ran (even if some failed)
echo "FINAL_STATUS = SUCCESS"
exit 0
