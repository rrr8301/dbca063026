#!/bin/bash

# Activate Python environment
python3.12 -m venv venv
source venv/bin/activate

# Install project dependencies
# Assuming dependencies are managed by Bazel, no additional pip installs are needed

# Build the project
bazel run //fleetbench:requirements.update
bazel build -c fastbuild //...

# Run tests
bazel test -c fastbuild --test_output=errors //...