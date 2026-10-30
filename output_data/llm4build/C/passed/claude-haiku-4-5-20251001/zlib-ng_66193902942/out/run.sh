#!/bin/bash
set -e

# Clone the main repository
git clone https://github.com/zlib-ng/zlib-ng.git /workspace/repo
cd /workspace/repo

# Clone test corpora
git clone https://github.com/zlib-ng/corpora.git test/data/corpora

# Generate project files
cmake -S . -DWITH_SANITIZER=Address -DWITH_BENCHMARKS=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DWITH_FUZZERS=ON \
  -DWITH_MAINTAINER_WARNINGS=ON \
  -DWITH_CODE_COVERAGE=ON \
  -B build
cd build

# Compile source code
cmake --build . --verbose -j2 --config Release

# Run test cases
export ASAN_OPTIONS="verbosity=0:abort_on_error=1:halt_on_error=1"
export MSAN_OPTIONS="verbosity=0:abort_on_error=1:halt_on_error=1"
export TSAN_OPTIONS="verbosity=0:abort_on_error=1:halt_on_error=1"
export LSAN_OPTIONS="verbosity=0:abort_on_error=1:halt_on_error=1"
export UBSAN_OPTIONS="verbosity=0:print_stacktrace=1:abort_on_error=1:halt_on_error=1"

ctest --verbose -C Release -E benchmark_zlib --output-on-failure --max-width 120 -j 3

# Generate coverage report
cd /workspace/repo
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

# Test benchmarks (crashtest only, no coverage data collection)
cd /workspace/repo/build
ctest --verbose -C Release -R ^benchmark_zlib$ --output-on-failure --max-width 120 -j 3

echo "All tests completed successfully!"