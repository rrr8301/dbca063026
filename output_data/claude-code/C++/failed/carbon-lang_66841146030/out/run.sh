#!/usr/bin/env bash

set -e

cd /app

# Set up Bazel configuration
export BAZEL_USE_CPP_ONLY_TOOLCHAIN=1
export CACHE_VERSION=1

# Create the targets file for all tests
TARGETS_FILE="/tmp/targets"
echo "//..." > $TARGETS_FILE

# Print tool debugging info
echo '*** PATH'
echo $PATH
echo '*** python'
which python3.10
python3.10 --version
echo '*** clang'
which clang
clang --version
echo '*** clang++'
which clang++
clang++ --version

# Configure Bazel
cat > user.bazelrc <<'EOF'
# Disable the local disk cache as we use a remote cache and don't want
# two copies of every output taking up disk space.
build --disk_cache=

# Allow passing targets that are incompatible
build --skip_incompatible_explicit_targets

# Set an artificially high jobs count
build --jobs=32

# Avoid any cache impact from build stamping
build --nostamp

# General build options
build --verbose_failures
test --test_output=errors
EOF

./scripts/run_bazel.py info

# Run module deps sync with retry
echo "Running module deps sync..."
./scripts/run_bazel.py --attempts=5 --retry-all-errors \
  mod --lockfile_mode=off deps
./scripts/run_bazel.py --attempts=5 --retry-all-errors \
  cquery --lockfile_mode=off //... | wc -l

# Run the tests
echo "Running tests with config opt..."
./scripts/run_bazel.py \
  --attempts=5 --jobs-on-last-attempt=4 \
  test -c opt \
  --target_pattern_file=$TARGETS_FILE

# If we reach here, tests ran successfully
echo "FINAL_STATUS = SUCCESS"
