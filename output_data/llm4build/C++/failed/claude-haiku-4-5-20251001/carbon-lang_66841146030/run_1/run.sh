#!/bin/bash

set -e

# Print tool versions for debugging
echo "=== Tool Versions ==="
echo "Python:"
python --version
echo "Clang:"
clang --version
echo "Clang++:"
clang++ --version
echo "Clang-tidy:"
clang-tidy --version
echo "Bazelisk:"
bazelisk --version
echo "Git:"
git --version
echo ""

# Configure Bazel
echo "=== Configuring Bazel ==="
cat > user.bazelrc <<'EOF'
# Disable the local disk cache
build --disk_cache=

# Enable remote cache for our CI but minimize downloads.
build --remote_cache=https://storage.googleapis.com/carbon-builds-github-v1
build --remote_download_outputs=minimal

# Set action environment
build --action_env=BAZEL_REMOTE_CACHE_KEY=local-build

# Set jobs count
build --jobs=32

# Avoid any cache impact from build stamping in CI.
build --nostamp

# General build options.
build --verbose_failures
test --test_output=errors
EOF

echo "=== Running Bazel info ==="
./scripts/run_bazel.py info

echo "=== Syncing Bazel dependencies ==="
./scripts/run_bazel.py --attempts=5 --retry-all-errors \
  mod --lockfile_mode=off deps
./scripts/run_bazel.py --attempts=5 --retry-all-errors \
  cquery --lockfile_mode=off //... | wc -l

echo "=== Disk space before build ==="
df -h

echo "=== Verifying MODULE.bazel.lock ==="
exit_code=0
./scripts/run_bazel.py \
  --attempts=5 \
  mod deps --lockfile_mode=error || exit_code=$?
if (( $exit_code != 0 )); then
  echo "WARNING: MODULE.bazel.lock is out of date, attempting update..."
  ./scripts/run_bazel.py \
    --attempts=5 \
    mod deps --lockfile_mode=update
fi

echo "=== Computing test targets ==="
# For local builds, use all targets as a fallback
TARGETS_FILE="/tmp/targets"
echo "//..." > $TARGETS_FILE

echo "=== Running Bazel tests ==="
export BAZEL_USE_CPP_ONLY_TOOLCHAIN=1
export TARGETS_FILE=$TARGETS_FILE

./scripts/run_bazel.py \
  --attempts=5 --jobs-on-last-attempt=4 \
  test -c opt \
  --target_pattern_file=$TARGETS_FILE

echo "=== Disk space after build ==="
df -h

echo "=== Tests completed successfully ==="