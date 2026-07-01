#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone . /app

# Change to the app directory
cd /app

# Run tests using Bazel
if [ -n "${BUILDBUDDY_ORG_API_KEY}" ]; then
    echo "Running with BuildBuddy ci config"
    bazel test --config=ci --remote_header=x-buildbuddy-api-key=${BUILDBUDDY_ORG_API_KEY} //...
else
    echo "Running without BuildBuddy (no API key)"
    bazel test //...
fi