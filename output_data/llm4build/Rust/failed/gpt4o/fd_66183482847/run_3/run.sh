#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Activate Rust environment
source $HOME/.cargo/env

# Determine build command
BUILD_CMD="cargo"
if [ "${USE_CROSS}" = "true" ]; then
  BUILD_CMD="cross"
fi

# Build the project
$BUILD_CMD build --locked --release --target="${TARGET}"

# Run tests
$BUILD_CMD test --locked --target="${TARGET}" "${CARGO_TEST_OPTIONS}"

# Generate completions
make completions

# Create tarball
PKG_SUFFIX=".tar.gz"
PKG_BASENAME="${NAME}-v${VERSION}-${TARGET}"
PKG_NAME="${PKG_BASENAME}${PKG_SUFFIX}"
PKG_STAGING="${CICD_INTERMEDIATES_DIR}/package"
ARCHIVE_DIR="${PKG_STAGING}/${PKG_BASENAME}/"
mkdir -p "${ARCHIVE_DIR}"

# Copy binary and other files
cp "target/${TARGET}/release/${NAME}" "${ARCHIVE_DIR}/${NAME}"  # Ensure binary is copied correctly
cp "README.md" "LICENSE-MIT" "LICENSE-APACHE" "CHANGELOG.md" "${ARCHIVE_DIR}"

# Ensure the doc and autocomplete directories exist before copying
if [ -f "doc/${NAME}.1" ]; then
  cp "doc/${NAME}.1" "${ARCHIVE_DIR}"
fi

if [ -d "autocomplete" ]; then
  cp -r autocomplete "${ARCHIVE_DIR}"
fi

# Create compressed package
pushd "${PKG_STAGING}/" >/dev/null
tar czf "${PKG_NAME}" "${PKG_BASENAME}"  # Corrected tar command
popd >/dev/null

# Create Debian package
if [[ "${OS}" == "ubuntu" ]]; then
  bash scripts/create-deb.sh
fi