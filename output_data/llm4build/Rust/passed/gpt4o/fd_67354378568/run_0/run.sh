#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install cross if needed
if [ "$USE_CROSS" = "true" ]; then
    CROSS_VERSION="v0.2.5"
    PACKAGE_NAME="cross-x86_64-unknown-linux-gnu.tar.gz"
    DIR="$HOME/.local/bin/"
    mkdir -p "$DIR"
    curl -L "https://github.com/cross-rs/cross/releases/download/${CROSS_VERSION}/${PACKAGE_NAME}" | tar -C "$DIR" -xz
    export PATH="$DIR:$PATH"
fi

# Show version information
gcc --version || true
rustup -V
rustup toolchain list
rustup default
cargo -V
rustc -V

# Build
$BUILD_CMD build --locked --release --target="${TARGET}"

# Set binary name & path
EXE_SUFFIX=""
case ${TARGET} in
  *-pc-windows-*) EXE_SUFFIX=".exe" ;;
esac
BIN_NAME="${NAME}${EXE_SUFFIX}"
BIN_PATH="target/${TARGET}/release/${BIN_NAME}"

# Run tests
CARGO_TEST_OPTIONS=""
case ${TARGET} in
  arm-* | aarch64-*)
    CARGO_TEST_OPTIONS="--bin=${NAME}" ;;
esac
$BUILD_CMD test --locked --target="${TARGET}" "${CARGO_TEST_OPTIONS}"

# Generate completions
make completions

# Create tarball
PKG_SUFFIX=".tar.gz"
case ${TARGET} in
  *-pc-windows-*) PKG_SUFFIX=".zip" ;;
esac
PKG_BASENAME="${NAME}-v${VERSION}-${TARGET}"
PKG_NAME="${PKG_BASENAME}${PKG_SUFFIX}"
PKG_STAGING="${CICD_INTERMEDIATES_DIR}/package"
ARCHIVE_DIR="${PKG_STAGING}/${PKG_BASENAME}/"
mkdir -p "${ARCHIVE_DIR}"

# Binary
cp "${BIN_PATH}" "$ARCHIVE_DIR"

# README, LICENSE and CHANGELOG files
cp "README.md" "LICENSE-MIT" "LICENSE-APACHE" "CHANGELOG.md" "$ARCHIVE_DIR"

# Man page
cp "doc/${NAME}.1" "$ARCHIVE_DIR"

# Autocompletion files
cp -r autocomplete "${ARCHIVE_DIR}"

# Base compressed package
pushd "${PKG_STAGING}/" >/dev/null
case ${TARGET} in
  *-pc-windows-*) 7z -y a "${PKG_NAME}" "${PKG_BASENAME}"/* | tail -2 ;;
  *) tar czf "${PKG_NAME}" "${PKG_BASENAME}"/* ;;
esac
popd >/dev/null

# Create Debian package
if [[ "${OS}" == "ubuntu" ]]; then
    bash scripts/create-deb.sh
fi