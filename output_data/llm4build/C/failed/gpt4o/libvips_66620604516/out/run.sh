#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone <repository-url> /app
cd /app

# Set environment variables
export CC=clang-19
export CXX=clang++-19
export LD=ld.lld-19
export CPPFLAGS="-Wall -g -fno-omit-frame-pointer -fno-sanitize=function -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION"
export LDFLAGS="-g -shared-libsan"
export ASAN_OPTIONS="suppressions=/app/suppressions/asan.supp:fast_unwind_on_malloc=0:allocator_may_return_null=1"
export LSAN_OPTIONS="suppressions=/app/suppressions/lsan.supp:fast_unwind_on_malloc=0"
export TSAN_OPTIONS="suppressions=/app/suppressions/tsan.supp:print_suppressions=1:ignore_noninstrumented_modules=1"
export UBSAN_OPTIONS="suppressions=/app/suppressions/ubsan.supp:halt_on_error=1:abort_on_error=1:print_stacktrace=1"
export PATH="$(dirname $($CC -print-prog-name=llvm-symbolizer)):$PATH"

# Prepare TSan
TSAN_DSO=$($CC -print-file-name=libclang_rt.tsan-x86_64.so)
export SANITIZE_DSO=$TSAN_DSO
export LD_LIBRARY_PATH=$(dirname $TSAN_DSO)

# Configure libvips
meson setup build \
  -Ddebug=true \
  -Ddeprecated=false \
  -Dmagick=disabled \
  -Ddocs=false \
  -Dintrospection=disabled \
  -Dfuzz=true \
  -Db_sanitize=thread \
  -Db_lundef=false || (cat build/meson-logs/meson-log.txt && exit 1)

# Build libvips
meson compile -C build

# Check libvips
meson test -C build --timeout-multiplier=0 || (cat build/meson-logs/testlog.txt && exit 1)

# Install libvips
sudo meson install -C build

# Rebuild the shared library cache
sudo ldconfig

# Run test suite
export VIPS_LEAK=1
export LD_PRELOAD=$SANITIZE_DSO
python3 -m pytest -sv --log-cli-level=WARNING test/test-suite || true