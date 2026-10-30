#!/bin/bash
set -e

# Set HOME and ensure Rust environment is available
export HOME="${HOME:-/root}"
export PATH="${HOME}/.cargo/bin:${PATH}"

# Source Rust environment if it exists
if [ -f "${HOME}/.cargo/env" ]; then
    source "${HOME}/.cargo/env"
fi

# Environment variables
export CICD_INTERMEDIATES_DIR="_cicd-intermediates"
export MSRV_FEATURES="--all-features"
export BUILD_CMD="cross"
export target="i686-unknown-linux-gnu"
export name="fd"

# Verify Rust is available
if ! command -v rustup &> /dev/null; then
    echo "Error: rustup not found in PATH"
    echo "PATH: $PATH"
    exit 1
fi

# Install Rust target
echo "Installing Rust target: $target"
rustup target add "$target"

# Install cross
echo "Installing cross v0.2.5"
cross_version="v0.2.5"
package_name="cross-x86_64-unknown-linux-gnu.tar.gz"
dir="$HOME/.local/bin/"
mkdir -p "$dir"

# Download cross binary
curl -L "https://github.com/cross-rs/cross/releases/download/${cross_version}/${package_name}" \
  -o /tmp/"${package_name}"
tar -C "$dir" -xz -f /tmp/"${package_name}"
rm /tmp/"${package_name}"
export PATH="$dir:$PATH"

echo "Installed cross $cross_version"

# Show version information
echo "=== Version Information ==="
gcc --version || true
rustup -V
rustup toolchain list
rustup default
cargo -V
rustc -V
cross --version || true

# Build
echo "=== Building ==="
cross build --locked --release --target="$target"

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
cross test --locked --target="$target" ${CARGO_TEST_OPTIONS:-}

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