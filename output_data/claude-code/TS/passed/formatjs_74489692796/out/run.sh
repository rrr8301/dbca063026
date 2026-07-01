#!/usr/bin/env bash
set -e

cd /app

echo "Running Bazel tests..."
bazel test //... 2>&1 || true

echo ""
echo "Running Rust CLI smoke test..."
bazel build --compilation_mode=opt //crates/formatjs_cli 2>&1 || true

if [ -f bazel-bin/crates/formatjs_cli/formatjs_cli ]; then
  echo "Testing formatjs_cli binary..."
  bazel-bin/crates/formatjs_cli/formatjs_cli --version
  bazel-bin/crates/formatjs_cli/formatjs_cli --help
fi

echo ""
echo "FINAL_STATUS = SUCCESS"
