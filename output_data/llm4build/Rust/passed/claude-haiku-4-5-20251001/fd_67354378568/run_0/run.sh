#!/bin/bash
set -e

# Source Rust environment
. $HOME/.cargo/env

# Environment variables
export CICD_INTERMEDIATES_DIR="_cicd-intermediates"
export MSRV_FEATURES="--all-features"
export BUILD_CMD="cross"
export target="i686-unknown-linux-gnu"
export name="fd"

# Install Rust toolchain and target
echo "Installing Rust toolchain and target..."
rustup toolchain install stable
rustup target add i686-unknown-linux-gnu --toolchain stable
rustup default stable

# Install cross
echo "Installing cross v0.2.5..."
dir="$HOME/.local/bin/"
mkdir -p "$dir"
cross_version="v0.2.5"
package_name="cross-x86_64-unknown-linux-gnu.tar.gz"

# Download cross from GitHub releases (without auth token)
gh release download --repo cross-rs/cross \
  --pattern "${package_name}" -O - "${cross_version}" \
  | tar -C "$dir" -xz

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
cross build --locked --release --target="i686-unknown-linux-gnu"

# Set binary name & path
EXE_suffix=""
case i686-unknown-linux-gnu in
  *-pc-windows-*) EXE_suffix=".exe" ;;
esac
BIN_NAME="fd${EXE_suffix}"
BIN_PATH="target/i686-unknown-linux-gnu/release/${BIN_NAME}"

echo "Binary path: ${BIN_PATH}"
echo "Binary name: ${BIN_NAME}"

# Set testing options
unset CARGO_TEST_OPTIONS
case i686-unknown-linux-gnu in
arm-* | aarch64-*)
  CARGO_TEST_OPTIONS="--bin=fd" ;;
esac

# Run tests
echo "=== Running Tests ==="
cross test --locked --target="i686-unknown-linux-gnu" ${CARGO_TEST_OPTIONS}

# Generate completions
echo "=== Generating Completions ==="
make completions

# Create tarball
echo "=== Creating Tarball ==="
PKG_suffix=".tar.gz"
case i686-unknown-linux-gnu in
*-pc-windows-*) PKG_suffix=".zip" ;;
esac
PKG_BASENAME="fd-v0.0.0-i686-unknown-linux-gnu"
PKG_NAME="${PKG_BASENAME}${PKG_suffix}"
PKG_STAGING="${CICD_INTERMEDIATES_DIR}/package"
ARCHIVE_DIR="${PKG_STAGING}/${PKG_BASENAME}/"

mkdir -p "${ARCHIVE_DIR}"
cp "${BIN_PATH}" "$ARCHIVE_DIR"
cp "README.md" "LICENSE-MIT" "LICENSE-APACHE" "CHANGELOG.md" "$ARCHIVE_DIR"
cp "doc/fd.1" "$ARCHIVE_DIR"
cp -r autocomplete "${ARCHIVE_DIR}"

pushd "${PKG_STAGING}/" >/dev/null
case i686-unknown-linux-gnu in
  *-pc-windows-*) 7z -y a "${PKG_NAME}" "${PKG_BASENAME}"/* | tail -2 ;;
  *) tar czf "${PKG_NAME}" "${PKG_BASENAME}"/* ;;
esac
popd >/dev/null

PKG_PATH="${PKG_STAGING}/${PKG_NAME}"
echo "Package created: ${PKG_PATH}"

# Create Debian package
echo "=== Creating Debian Package ==="
export TARGET="i686-unknown-linux-gnu"
export DPKG_VERSION="0.0.0"
export BIN_PATH="${BIN_PATH}"

bash scripts/create-deb.sh || echo "Debian package creation skipped or failed (may not be applicable for this target)"

echo "=== Build Complete ==="