#!/usr/bin/env bash

set -eux

cd /app

# Mark repo as safe for git (required for meson to work properly)
git config --global --add safe.directory "$PWD"

# Run the build script with debug buildtype, clang compiler, and valgrind support
scripts/build.sh -b debug -c clang -x

# Check if build succeeded
if [ $? -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
