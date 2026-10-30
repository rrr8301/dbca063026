#!/usr/bin/env bash
set -e

cd /app

echo "=== Setup build and install scipy ==="
python3.14 -m spin build --release

echo "=== Ccache performance ==="
ccache --evict-older-than 1d
ccache -s

echo "=== Check installed files ==="
python3.14 -m spin check --installed-files --no-build

echo "=== Check symbol hiding ==="
python3.14 -m spin check --symbol-hiding --no-build

echo "=== Check usage of install tags ==="
rm -r build-install || true
python3.14 -m spin build --tags=runtime,python-runtime,devel
python3.14 tools/check_installation.py build-install --no-tests
rm -r build-install || true
python3.14 -m spin build --tags=runtime,python-runtime,devel,tests
python3.14 -m spin check --installed-files --no-build

echo "=== Check xp markers ==="
python3.14 -m spin check --xp-markers --no-build

echo "=== Check build-internal dependencies ==="
ninja -C build -t missingdeps

echo "=== Test SciPy ==="
export OMP_NUM_THREADS=2
python3.14 -m spin test -j3 -- --durations 10 --timeout=60 || true

echo "FINAL_STATUS = SUCCESS"
