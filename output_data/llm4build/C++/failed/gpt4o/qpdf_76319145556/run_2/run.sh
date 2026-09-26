#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Activate environment variables
export QTEST_COLOR=1

# Run the build and test script
bash build-scripts/build-linux