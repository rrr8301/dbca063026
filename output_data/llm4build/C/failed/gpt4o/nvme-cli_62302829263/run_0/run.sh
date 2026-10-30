#!/bin/bash

# Mark repo as safe for git
git config --global --add safe.directory "$(pwd)"

# Run the build script
scripts/build.sh -b debug -c gcc -x libnvme