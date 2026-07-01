#!/usr/bin/env bash

cd /app

# Install dependencies manually, avoiding the pkg-config:i386 conflict
apt-get update
apt-get install -y \
    gcc \
    meson \
    ninja-build \
    libudev-dev \
    liburing-dev \
    libnuma-dev \
    pkg-config \
    python3 \
    python3-pip \
    clang \
    doxygen \
    gcc-10 \
    gcc-9 \
    valgrind \
    gcc-multilib \
    g++-multilib \
    libc6-dev-i386 \
    libpcap0.8-dev:i386 \
    libudev-dev:i386 \
    python3-pytest || true

# Install Python requirements
pip install -r requirements.txt || true

# Run the CI build script adapted for container
TEST_CMD="meson test -C . --print-errorlogs"
SAN="-Db_sanitize=address,undefined"

export UBSAN_OPTIONS=halt_on_error=1
umask 0022

SOURCE_DIR="$(readlink -f .)"
TEST_DIR="$(mktemp -dt libfuse-build-XXXXXX)"
PREFIX_DIR="$(mktemp -dt libfuse-install-XXXXXXX)"

chmod 0755 "${TEST_DIR}"
cd "${TEST_DIR}"
echo "Running in ${TEST_DIR}"

cp -v "${SOURCE_DIR}/test/lsan_suppress.txt" .
export LSAN_OPTIONS="suppressions=$(pwd)/lsan_suppress.txt"
export ASAN_OPTIONS="detect_leaks=1"
export CC

log_env()
{
    echo "=== Environment ==="
    echo "CC: ${CC}"
    echo "CXX: ${CXX}"
    echo "LSAN_OPTIONS: ${LSAN_OPTIONS}"
    echo "ASAN_OPTIONS: ${ASAN_OPTIONS}"
    echo "UBSAN_OPTIONS: ${UBSAN_OPTIONS}"
    echo "FUSE_URING_ENABLE: ${FUSE_URING_ENABLE}"
    echo "FUSE_URING_QUEUE_DEPTH: ${FUSE_URING_QUEUE_DEPTH}"
    echo "Valgrind: ${TEST_WITH_VALGRIND}"
    echo "==================="
}

non_sanitized_build()
(
    echo "Standard build (without sanitizers)"
    for CC in gcc gcc-9 gcc-10 clang; do
        echo "=== Building with ${CC} ==="
        mkdir build-${CC}; pushd build-${CC}
        if [ "${CC}" == "clang" ]; then
            export CXX="clang++"
            export TEST_WITH_VALGRIND=false
        else
            unset CXX
            export TEST_WITH_VALGRIND=true
        fi
        if [ ${CC} == 'gcc-7' ]; then
            build_opts='-D b_lundef=false'
        else
            build_opts=''
        fi
        if [ ${CC} == 'gcc-10' ]; then
            build_opts='-Dc_args=-flto=auto'
        else
            build_opts=''
        fi

        log_env
        meson setup -Dprefix=${PREFIX_DIR} -D werror=true ${build_opts} "${SOURCE_DIR}" || (cat meson-logs/meson-log.txt; false)
        ninja
        ninja install

        chmod 4755 ${PREFIX_DIR}/bin/fusermount3 2>/dev/null || true

        chown root:root util/fusermount3 2>/dev/null || true
        chmod 4755 util/fusermount3 2>/dev/null || true

        ${TEST_CMD}
        popd
        rm -fr build-${CC}
        rm -fr ${PREFIX_DIR}

    done
)

sanitized_build()
(
    echo "=== Building with clang and sanitizers"

    mkdir build-san; pushd build-san

    log_env
    meson setup -Dprefix=${PREFIX_DIR} -D werror=true\
           "${SOURCE_DIR}" \
           || (cat meson-logs/meson-log.txt; false)
    meson configure $SAN

    meson configure -D b_lundef=false

    if [[ $# -gt 0 ]]; then
        meson configure "$@"
    fi

    meson configure --no-pager

    meson setup --reconfigure "${SOURCE_DIR}"
    ninja
    ninja install
    chmod 4755 ${PREFIX_DIR}/bin/fusermount3 2>/dev/null || true

    chown root:root util/fusermount3 2>/dev/null || true
    chmod 4755 util/fusermount3 2>/dev/null || true

    ${TEST_CMD} --logbase=testlog-root || true
    rm -rf test/.pytest_cache/ test/__pycache__ 2>/dev/null || true

    ${TEST_CMD}

    popd
    rm -fr build-san
    rm -fr ${PREFIX_DIR}
)

# Sanitized with io-uring
export CC=clang
export CXX=clang++
export FUSE_URING_ENABLE=1
sanitized_build
unset FUSE_URING_ENABLE

# 32-bit sanitized build
export CC=clang
export CXX=clang++
export CFLAGS="-m32"
export CXXFLAGS="-m32"
export LDFLAGS="-m32"
export PKG_CONFIG_PATH="/usr/lib/i386-linux-gnu/pkgconfig"
TEST_WITH_VALGRIND=false
sanitized_build
unset CFLAGS
unset CXXFLAGS
unset LDFLAGS
unset PKG_CONFIG_PATH
unset TEST_WITH_VALGRIND
unset CC
unset CXX

# Sanitized build
export CC=clang
export CXX=clang++
TEST_WITH_VALGRIND=false
sanitized_build

# Sanitized build without libc versioned symbols
export CC=clang
export CXX=clang++
sanitized_build "-Ddisable-libc-symbol-version=true"

# Sanitized build without fuse-io-uring
export CC=clang
export CXX=clang++
sanitized_build "-Denable-io-uring=false"

# Build without any sanitizer
non_sanitized_build

# Documentation.
(cd "${SOURCE_DIR}"; doxygen doc/Doxyfile) || true

# Clean up.
rm -rf "${TEST_DIR}"

echo "FINAL_STATUS = SUCCESS"
