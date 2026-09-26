#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Run tests
if [ -n "${BUILDBUDDY_ORG_API_KEY}" ]; then
    echo "Running with BuildBuddy ci config"
    bazel test --config=ci --remote_header=x-buildbuddy-api-key=${BUILDBUDDY_ORG_API_KEY} //...
else
    echo "Running without BuildBuddy (no API key)"
    bazel test //...
fi

# Rust CLI Smoke Test
if [ -n "${BUILDBUDDY_ORG_API_KEY}" ]; then
    bazel build \
      --config=ci \
      --compilation_mode=opt \
      --remote_download_outputs=all \
      --remote_header=x-buildbuddy-api-key=${BUILDBUDDY_ORG_API_KEY} \
      //crates/formatjs_cli
else
    bazel build --compilation_mode=opt //crates/formatjs_cli
fi

BINARY_PATH=bazel-bin/crates/formatjs_cli/formatjs_cli
$BINARY_PATH --version
$BINARY_PATH --help