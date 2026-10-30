#!/usr/bin/env bash
set -e

echo "===== Starting SciPy CI Job Reproduction ====="

cd /app

echo "===== Building SciPy with spin build --release ====="
spin build --release

echo "===== Check installed files ====="
spin check --installed-files --no-build

echo "===== Check symbol hiding ====="
spin check --symbol-hiding --no-build

echo "===== Check usage of install tags ====="
rm -rf build-install
spin build --tags=runtime,python-runtime,devel
python tools/check_installation.py build-install --no-tests
rm -rf build-install
spin build --tags=runtime,python-runtime,devel,tests
spin check --installed-files --no-build

echo "===== Check xp markers ====="
spin check --xp-markers --no-build

echo "===== Check build-internal dependencies ====="
ninja -C build -t missingdeps

echo "===== Running mypy ====="
python -m pip install mypy==1.19.1 types-psutil typing_extensions pybind11 sphinx || true
spin mypy || true

echo "===== Running Tests ====="
export OMP_NUM_THREADS=2
spin test -j3 -- --durations 10 --timeout=60

echo "===== All tests completed ====="
FINAL_STATUS=SUCCESS
