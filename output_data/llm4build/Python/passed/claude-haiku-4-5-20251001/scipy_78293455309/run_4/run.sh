#!/bin/bash
set -e

# Ensure git is configured
git config --global --add safe.directory '*'

# Initialize ccache
mkdir -p "${CCACHE_DIR}"
ccache --zero-stats || true

# Build SciPy with spin
echo "Building SciPy..."
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

# Run mypy
echo "Running mypy..."
python -m mypy --version
spin mypy

# Run pyrefly
echo "Running pyrefly..."
pyrefly check --output-format=github

# Run tests
echo "Running SciPy tests..."
export OMP_NUM_THREADS=2
spin test -j3 -- --durations 10 --timeout=60

# Print ccache stats
echo "Ccache performance:"
ccache --evict-older-than 1d || true
ccache -s || true

echo "All checks and tests completed successfully!"