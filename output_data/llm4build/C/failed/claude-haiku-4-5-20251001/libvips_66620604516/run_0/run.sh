#!/bin/bash

set -e

# Enable error handling: continue on test failures but report them
TEST_FAILED=0

# Prepare sanitizers environment
export CPPFLAGS="-g -fno-omit-frame-pointer -fno-sanitize=function -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION"
export LDFLAGS="-g -shared-libsan"
export ASAN_OPTIONS="suppressions=/workspace/suppressions/asan.supp:fast_unwind_on_malloc=0:allocator_may_return_null=1"
export LSAN_OPTIONS="suppressions=/workspace/suppressions/lsan.supp:fast_unwind_on_malloc=0"
export TSAN_OPTIONS="suppressions=/workspace/suppressions/tsan.supp:print_suppressions=1:ignore_noninstrumented_modules=1"
export UBSAN_OPTIONS="suppressions=/workspace/suppressions/ubsan.supp:halt_on_error=1:abort_on_error=1:print_stacktrace=1"

# Add llvm-symbolizer to PATH
LLVM_SYMBOLIZER_PATH=$(dirname $(clang-19 -print-prog-name=llvm-symbolizer))
export PATH="$LLVM_SYMBOLIZER_PATH:$PATH"

# Prepare TSan
TSAN_DSO=$(clang-19 -print-file-name=libclang_rt.tsan-x86_64.so)
export SANITIZE_DSO="$TSAN_DSO"
export LD_LIBRARY_PATH="$(dirname $TSAN_DSO)"

echo "=== Environment Setup ==="
echo "CC: $CC"
echo "CXX: $CXX"
echo "LD: $LD"
echo "SANITIZE_DSO: $SANITIZE_DSO"
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo ""

# Configure libvips
echo "=== Configuring libvips ==="
meson setup build \
  -Ddebug=true \
  -Ddeprecated=false \
  -Dmagick=disabled \
  -Ddocs=false \
  -Dintrospection=disabled \
  -Dfuzz=true \
  -Db_sanitize=thread \
  -Db_lundef=false \
  || (cat build/meson-logs/meson-log.txt && exit 1)

echo ""
echo "=== Building libvips ==="
meson compile -C build

echo ""
echo "=== Running libvips test suite ==="
meson test -C build --timeout-multiplier=0 \
  || (cat build/meson-logs/testlog.txt && exit 1)

echo ""
echo "=== Installing libvips ==="
meson install -C build

echo ""
echo "=== Rebuilding shared library cache ==="
ldconfig

echo ""
echo "=== Installing pyvips ==="
pip3 install pyvips[test] --break-system-packages

echo ""
echo "=== Running Python test suite ==="
export VIPS_LEAK=1
export LD_PRELOAD="$SANITIZE_DSO"

python3 -m pytest -sv --log-cli-level=WARNING test/test-suite || TEST_FAILED=1

echo ""
if [ $TEST_FAILED -eq 0 ]; then
  echo "=== All tests passed ==="
  exit 0
else
  echo "=== Some tests failed ==="
  exit 1
fi