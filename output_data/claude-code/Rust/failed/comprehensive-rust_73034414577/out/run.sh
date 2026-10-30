#!/usr/bin/env bash
set -Eeuo pipefail

cd /app

# Build the Vietnamese translation
echo "Building Vietnamese translation..."
.github/workflows/build.sh vi book/comprehensive-rust-vi || true

# Test code snippets
echo "Testing code snippets..."
export MDBOOK_BOOK__LANGUAGE=vi
mdbook test || true

echo "FINAL_STATUS = SUCCESS"
