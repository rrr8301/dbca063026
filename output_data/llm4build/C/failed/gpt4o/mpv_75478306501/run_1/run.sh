#!/bin/bash

# Build with Meson
./ci/build-tumbleweed.sh -Db_ndebug=true

# Run Meson tests
meson test -C build

# Print Meson test log if tests fail
if [ $? -ne 0 ]; then
  cat ./build/meson-logs/testlog.txt
fi