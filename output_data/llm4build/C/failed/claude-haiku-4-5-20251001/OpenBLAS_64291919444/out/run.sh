#!/bin/bash
set -e

# Enable ccache
export PATH="/usr/lib/ccache:$PATH"

# Configure ccache
mkdir -p ~/.ccache
cat > ~/.ccache/ccache.conf << EOF
max_size = 250M
compression = true
EOF

ccache -p
ccache -s

# Configure OpenBLAS
mkdir -p build
cd build

cmake -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS=ON \
      -DBUILD_STATIC_LIBS=ON \
      -DDYNAMIC_ARCH=ON \
      -DUSE_THREAD=ON \
      -DNUM_THREADS=64 \
      -DTARGET=CORE2 \
      -DCMAKE_C_COMPILER_LAUNCHER=ccache \
      -DCMAKE_Fortran_COMPILER_LAUNCHER=ccache \
      ..

# Build OpenBLAS
cmake --build .

# Show ccache status
ccache -s || true

# Run tests
echo "Running ctest..."
ctest || TEST_FAILED=1

# Re-run failed tests if any failed
if [ "${TEST_FAILED}" = "1" ]; then
  echo "::group::Re-run ctest"
  ctest --rerun-failed --output-on-failure || true
  echo "::endgroup::"
  echo "::group::Log from these tests"
  if [ -f Testing/Temporary/LastTest.log ]; then
    cat Testing/Temporary/LastTest.log
  fi
  echo "::endgroup::"
  exit 1
fi

echo "All tests passed!"