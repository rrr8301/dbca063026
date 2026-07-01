#!/bin/bash
set -e

# Mark repo as safe for git
git config --global --add safe.directory "$PWD"

# Build libnvme with debug configuration using gcc
scripts/build.sh -b debug -c gcc -x libnvme

echo "Build completed successfully"