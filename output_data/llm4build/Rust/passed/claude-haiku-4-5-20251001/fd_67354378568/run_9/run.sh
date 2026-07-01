#!/bin/bash
set -e

# Set HOME and Rust environment variables
export HOME="${HOME:-/root}"
export RUSTUP_HOME="${HOME}/.rustup"
export CARGO_HOME="${HOME}/.cargo"
export PATH="${CARGO_HOME}/bin:${PATH}"

# Verify Rust is available
if ! command -v rustup &> /dev/null; then
    echo "Error: rustup not found in PATH"
    echo "PATH: $PATH"
    echo "HOME: $HOME"
    echo "CARGO_HOME: $CARGO_HOME"
    echo "Checking for cargo binary:"
    ls -la "${CARGO_HOME}/bin/" 2>/dev/null || echo "Directory does not exist"
    exit 1
fi

# Environment variables
export CICD_INTERMEDIATES_DIR="_cicd-intermediates"
export MSRV_FEATURES="--all-features"
export BUILD_CMD="cargo"
export target="i686-unknown-linux-gnu"
export name="fd"

# Install Rust target
echo "Installing Rust target: $target"
rustup target add "$target"

# Show version information
echo "=== Version Information ==="
gcc --version || true
rustup -V
rustup toolchain list
rustup default
cargo -V
rustc -V

# Build
echo "=== Building ==="
cargo build --locked --release --target="$target"

# Set binary name and path
EXE_suffix=""
case "$target" in
  *-pc-windows-*) EXE_suffix=".exe" ;;
esac
BIN_NAME="fd${EXE_suffix}"
BIN_PATH="target/$target/release/${BIN_NAME}"

echo "Binary path: $BIN_PATH"

# Set testing options
unset CARGO_TEST_OPTIONS
case "$target" in
  arm-* | aarch64-*)
    CARGO_TEST_OPTIONS="--bin=fd" ;;
esac

# Run tests
echo "=== Running Tests ==="
cargo test --locked --target="$target" ${CARGO_TEST_OPTIONS:-}

# Generate completions
echo "=== Generating Completions ==="
make completions

# Create tarball
echo "=== Creating Tarball ==="
PKG_suffix=".tar.gz"
case "$target" in
  *-pc-windows-*) PKG_suffix=".zip" ;;
esac
PKG_BASENAME="fd-v0.0.0-$target"
PKG_NAME="${PKG_BASENAME}${PKG_suffix}"
PKG_STAGING="${CICD_INTERMEDIATES_DIR}/package"
ARCHIVE_DIR="${PKG_STAGING}/${PKG_BASENAME}/"
mkdir -p "${ARCHIVE_DIR}"

cp "${BIN_PATH}" "$ARCHIVE_DIR"
cp "README.md" "LICENSE-MIT" "LICENSE-APACHE" "CHANGELOG.md" "$ARCHIVE_DIR"
cp "doc/fd.1" "$ARCHIVE_DIR"
cp -r autocomplete "${ARCHIVE_DIR}"

pushd "${PKG_STAGING}/" >/dev/null
case "$target" in
  *-pc-windows-*)
    7z -y a "${PKG_NAME}" "${PKG_BASENAME}"/* | tail -2 ;;
  *)
    tar czf "${PKG_NAME}" "${PKG_BASENAME}"/* ;;
esac
popd >/dev/null

echo "Package created: ${PKG_STAGING}/${PKG_NAME}"

# Create Debian package
echo "=== Creating Debian Package ==="
export TARGET="$target"
export DPKG_VERSION="0.0.0"
export BIN_PATH="$BIN_PATH"
bash scripts/create-deb.sh || echo "Debian package creation skipped or failed (may not be applicable for this target)"

echo "=== Build Complete ==="