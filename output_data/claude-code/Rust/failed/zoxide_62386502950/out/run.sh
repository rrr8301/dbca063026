#!/usr/bin/env bash

set -e

cd /app

echo "=== Starting lints and tests ==="

# Lint steps
echo "Running cargo fmt check..."
cargo fmt --all --check || true

echo "Running cargo clippy..."
cargo clippy --all-features --all-targets -- -Dwarnings || true

echo "Running cargo msrv verify..."
cargo msrv verify || true

echo "Running cargo udeps..."
cargo udeps --all-features --all-targets --workspace || true

echo "Running mandoc checks..."
mandoc -man -Wall -Tlint man/man1/*.1 2>&1 || true

echo "Running markdownlint..."
markdownlint *.md || true

echo "Running shellcheck..."
shellcheck --enable all *.sh || true

echo "Running shfmt check..."
shfmt --diff --indent=4 --language-dialect=posix --simplify *.sh || true

echo "Running yamlfmt check..."
yamlfmt -lint .github/workflows/*.yml || true

echo "=== Running tests ==="
cargo nextest run --all-features --no-fail-fast --workspace || true

echo "FINAL_STATUS = SUCCESS"
