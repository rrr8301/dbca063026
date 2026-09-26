#!/bin/bash

# Activate Python environment
python3.12 -m venv venv
source venv/bin/activate

# Install Python dependencies if any (placeholder)
# pip install -r requirements.txt

# Ensure Bazel is in the PATH
export PATH="$PATH:/usr/bin"

# Build the project
bazel run //fleetbench:requirements.update
bazel build -c fastbuild --config=clang //...

# Run tests
bazel test -c fastbuild --config=clang --test_output=errors //...

# Ensure all tests are executed
EXIT_CODE=0
bazel test -c fastbuild --config=clang --test_output=errors //... || EXIT_CODE=$?

exit $EXIT_CODE