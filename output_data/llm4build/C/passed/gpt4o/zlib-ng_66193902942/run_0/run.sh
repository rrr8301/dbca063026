#!/bin/bash

# Generate project files
cmake -S . -DWITH_SANITIZER=Address -DWITH_BENCHMARKS=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DWITH_FUZZERS=ON \
  -DWITH_MAINTAINER_WARNINGS=ON \
  -DWITH_CODE_COVERAGE=ON

# Compile source code
cmake --build . --verbose -j2 --config Release

# Run test cases
ctest --verbose -C Release -E benchmark_zlib --output-on-failure --max-width 120 -j 3

# Generate coverage report
python3 -u -m venv ./venv
source ./venv/bin/activate
python3 -u -m pip install gcovr
python3 -m gcovr -j 3 --gcov-ignore-parse-errors --verbose \
  --exclude '(.*/|^)(_deps|benchmarks)/.*' \
  --exclude-unreachable-branches \
  --merge-mode-functions separate \
  --merge-lines \
  --gcov-executable "gcov" \
  --xml --output ubuntu_gcc.xml

# Test benchmarks
ctest --verbose -C Release -R ^benchmark_zlib$ --output-on-failure --max-width 120 -j 3