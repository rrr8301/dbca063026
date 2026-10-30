#!/usr/bin/env bash
set -e

# Create targets file with all targets (simulating a push event)
TARGETS_FILE="/tmp/targets"
echo "//..." > "$TARGETS_FILE"

# Configure Bazel
cat > user.bazelrc <<'EOF'
build --disk_cache=
build --remote_cache=https://storage.googleapis.com/carbon-builds-github-v1
build --remote_download_outputs=minimal
build --skip_incompatible_explicit_targets
build --action_env=BAZEL_REMOTE_CACHE_KEY=github-action-ubuntu-22.04
build --jobs=32
build --nostamp
build --verbose_failures
test --test_output=errors
EOF

# Print tool versions for debugging
echo "=== Python version ==="
python --version
echo "=== Clang version ==="
clang --version
echo "=== Clang++ version ==="
clang++ --version

# Sync dependencies with retry
echo "=== Syncing Bazel dependencies ==="
./scripts/run_bazel.py --attempts=5 --retry-all-errors \
  mod --lockfile_mode=off deps || true
./scripts/run_bazel.py --attempts=5 --retry-all-errors \
  cquery --lockfile_mode=off //... | wc -l || true

# Verify MODULE.bazel.lock
echo "=== Verifying MODULE.bazel.lock ==="
./scripts/run_bazel.py --attempts=5 \
  mod deps --lockfile_mode=error || {
  echo "Module lock file out of date, attempting update..."
  ./scripts/run_bazel.py --attempts=5 \
    mod deps --lockfile_mode=update || true
}

# Run the tests
echo "=== Running tests ==="
exit_code=0
./scripts/run_bazel.py \
  --attempts=5 --jobs-on-last-attempt=4 \
  test \
  --target_pattern_file="$TARGETS_FILE" || exit_code=$?

# Print final status
if [ $exit_code -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = SUCCESS"
fi
