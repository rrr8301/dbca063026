#!/bin/bash
set -e

# Export environment variables
export OMP_NUM_THREADS=2
export CCACHE_DIR="${CCACHE_DIR:-.ccache}"
export CCACHE_MAXSIZE="250M"

# Initialize ccache
mkdir -p "${CCACHE_DIR}"
ccache --zero-stats

# Build scipy
echo "Building SciPy with spin..."
spin build --release

# Check installed files
echo "Checking installed files..."
spin check --installed-files --no-build

# Check symbol hiding
echo "Checking symbol hiding..."
spin check --symbol-hiding --no-build

# Check usage of install tags
echo "Checking install tags..."
rm -rf build-install
spin build --tags=runtime,python-runtime,devel
python tools/check_installation.py build-install --no-tests
rm -rf build-install
spin build --tags=runtime,python-runtime,devel,tests
spin check --installed-files --no-build

# Check xp markers
echo "Checking xp markers..."
spin check --xp-markers --no-build

# Check build-internal dependencies
echo "Checking build-internal dependencies..."
ninja -C build -t missingdeps

# Run tests
echo "Running SciPy tests..."
spin test -j3 -- --durations 10 --timeout=60

# Print ccache stats
echo "Ccache performance:"
ccache --evict-older-than 1d
ccache -s

echo "All tests completed successfully!"