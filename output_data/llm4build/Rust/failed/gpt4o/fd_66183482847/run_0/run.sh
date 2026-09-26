#!/bin/bash

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
cp "target/${TARGET}/release/${NAME}" "${ARCHIVE_DIR}"
cp "README.md" "LICENSE-MIT" "LICENSE-APACHE" "CHANGELOG.md" "${ARCHIVE_DIR}"
cp "doc/${NAME}.1" "${ARCHIVE_DIR}"
cp -r autocomplete "${ARCHIVE_DIR}"

# Create compressed package
pushd "${PKG_STAGING}/" >/dev/null
tar czf "${PKG_NAME}" "${PKG_BASENAME}"/*
popd >/dev/null

# Create Debian package
if [[ "${OS}" == "ubuntu" ]]; then
  bash scripts/create-deb.sh
fi