#!/bin/bash

# Activate environment variables
export CI=true
export GITHUB_ACTIONS=true

# Run the build script
scripts/build.sh -b debug -c clang -x