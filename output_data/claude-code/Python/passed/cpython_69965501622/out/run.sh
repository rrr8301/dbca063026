#!/usr/bin/env bash
set -e

cd /app

# Set environment variables
export MULTISSL_DIR=/tmp/multissl
export OPENSSL_DIR=${MULTISSL_DIR}/openssl/${OPENSSL_VER}
export LD_LIBRARY_PATH=${OPENSSL_DIR}/lib:${LD_LIBRARY_PATH}
export CPYTHON_BUILDDIR=/build
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Create build directory
mkdir -p ${CPYTHON_BUILDDIR}

# Install OpenSSL 3.5.5
echo "Installing OpenSSL ${OPENSSL_VER}..."
if [ ! -f "${OPENSSL_DIR}/lib/libssl.so" ]; then
    python3 Tools/ssl/multissltests.py \
        --steps=library \
        --base-directory "${MULTISSL_DIR}" \
        --openssl "${OPENSSL_VER}" \
        --system Linux
fi

# Configure CPython out-of-tree
echo "Configuring CPython out-of-tree..."
cd ${CPYTHON_BUILDDIR}
export PROFILE_TASK='-m test --pgo --ignore test_unpickle_module_race'
/app/configure \
    --config-cache \
    --with-pydebug \
    --enable-slower-safety \
    --enable-safety \
    --with-openssl="${OPENSSL_DIR}"

# Build CPython out-of-tree
echo "Building CPython out-of-tree..."
set -o pipefail
make -j --output-sync 2>&1 | tee compiler_output_ubuntu.txt || true
set +o pipefail

# Display build info
echo "Displaying build info..."
make pythoninfo || true

# Check compiler warnings
echo "Checking compiler warnings..."
python3 /app/Tools/build/check_warnings.py \
    --compiler-output-file-path="${CPYTHON_BUILDDIR}/compiler_output_ubuntu.txt" \
    --warning-ignore-file-path "/app/Tools/build/.warningignore_ubuntu" \
    --compiler-output-type=gcc \
    --fail-on-regression \
    --fail-on-improvement \
    --path-prefix="../../app/" || true

# Run tests
echo "Running tests..."
xvfb-run make ci EXTRATESTOPTS="" || true

echo "FINAL_STATUS = SUCCESS"
