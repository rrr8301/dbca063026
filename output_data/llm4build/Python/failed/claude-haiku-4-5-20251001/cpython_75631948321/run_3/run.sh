#!/bin/bash
set -e

# Set environment variables
export MULTISSL_DIR="${PWD}/multissl"
export OPENSSL_DIR="${MULTISSL_DIR}/openssl/${OPENSSL_VER}"
export LD_LIBRARY_PATH="${OPENSSL_DIR}/lib:${LD_LIBRARY_PATH}"
export CPYTHON_RO_SRCDIR="$(realpath -m "${PWD}/../cpython-ro-srcdir")"
export CPYTHON_BUILDDIR="$(realpath -m "${PWD}/../cpython-builddir")"

# Create directories for out-of-tree builds (requires sudo)
sudo mkdir -p "$CPYTHON_RO_SRCDIR" "$CPYTHON_BUILDDIR"
sudo chown testuser:testuser "$CPYTHON_RO_SRCDIR" "$CPYTHON_BUILDDIR"

# Copy sources to read-only source directory (simulating bind mount)
cp -r . "$CPYTHON_RO_SRCDIR/"

# Install OpenSSL if not already present
if [ ! -d "$OPENSSL_DIR" ]; then
    echo "Building OpenSSL ${OPENSSL_VER}..."
    python3 -W ignore::DeprecationWarning "$CPYTHON_RO_SRCDIR/Tools/ssl/multissltests.py" \
        --steps=library \
        --base-directory "$MULTISSL_DIR" \
        --openssl "$OPENSSL_VER" \
        --system Linux
fi

# Bind mount sources read-only (requires sudo)
sudo mount --bind -o ro "$PWD" "$CPYTHON_RO_SRCDIR"

# Configure CPython out-of-tree
echo "Configuring CPython..."
cd "$CPYTHON_BUILDDIR"
"$CPYTHON_RO_SRCDIR/configure" \
    --config-cache \
    --with-pydebug \
    --enable-slower-safety \
    --with-openssl="$OPENSSL_DIR"

# Build CPython
echo "Building CPython..."
make -j4

# Display build info
echo "Displaying build info..."
make pythoninfo

# Check compiler warnings
echo "Checking compiler warnings..."
make check-compiler-warnings

# Remount sources writable for tests (requires sudo)
sudo mount "$CPYTHON_RO_SRCDIR" -oremount,rw

# Run tests
echo "Running tests..."
make ci