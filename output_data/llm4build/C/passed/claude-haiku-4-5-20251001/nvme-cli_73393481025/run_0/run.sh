#!/bin/bash
set -e

# Mark repo as safe for git (required for git operations in container)
git config --global --add safe.directory "$PWD"

# Run the build script with the specified parameters
scripts/build.sh -b debug -c clang -x

echo "Build completed successfully"