#!/bin/bash

set -e

# Environment variables
export CICD_INTERMEDIATES_DIR="_cicd-intermediates"
export MSRV_FEATURES="--all-features"
export BUILD_CMD="cargo"
export target="x86_64-unknown-linux-musl"
export name="fd"

# Show version information
echo "=== Version Information ==="
gcc --version || true
rustup -V
rustup toolchain list
rustup default
cargo -V
rustc -V
echo ""

# Build
echo "=== Building ==="
cargo build --locked --release --target="x86_64-unknown-linux-musl"
echo "Build completed successfully"
echo ""

# Set binary path
BIN_NAME="fd"
BIN_PATH="target/x86_64-unknown-linux-musl/release/${BIN_NAME}"
echo "Binary path: ${BIN_PATH}"
echo ""

# Run tests
echo "=== Running Tests ==="
cargo test --locked --target="x86_64-unknown-linux-musl" || TEST_FAILED=1
if [ "${TEST_FAILED}" = "1" ]; then
    echo "Tests failed, but continuing with other steps..."
fi
echo ""

# Generate completions
echo "=== Generating Completions ==="
make completions
echo "Completions generated"
echo ""

# Create tarball
echo "=== Creating Tarball ==="
PKG_suffix=".tar.gz"
PKG_BASENAME="fd-v0.0.0-x86_64-unknown-linux-musl"
PKG_NAME="${PKG_BASENAME}${PKG_suffix}"

PKG_STAGING="${CICD_INTERMEDIATES_DIR}/package"
ARCHIVE_DIR="${PKG_STAGING}/${PKG_BASENAME}/"
mkdir -p "${ARCHIVE_DIR}"

cp "${BIN_PATH}" "$ARCHIVE_DIR"
cp "README.md" "LICENSE-MIT" "LICENSE-APACHE" "CHANGELOG.md" "$ARCHIVE_DIR"
cp "doc/fd.1" "$ARCHIVE_DIR"
cp -r autocomplete "${ARCHIVE_DIR}"

pushd "${PKG_STAGING}/" >/dev/null
tar czf "${PKG_NAME}" "${PKG_BASENAME}"/*
popd >/dev/null

PKG_PATH="${PKG_STAGING}/${PKG_NAME}"
echo "Tarball created at: ${PKG_PATH}"
echo ""

# Summary
echo "=== Build Summary ==="
echo "Package name: ${PKG_NAME}"
echo "Package path: ${PKG_PATH}"
echo "Binary: ${BIN_PATH}"

if [ "${TEST_FAILED}" = "1" ]; then
    echo "WARNING: Some tests failed during execution"
    exit 1
fi

echo "All steps completed successfully!"