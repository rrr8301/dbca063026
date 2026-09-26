#!/bin/bash

set -e

# Export environment variables
export TURBO_FLAGS='--concurrency=100% --filter "!./integrations/{java,rust,dotnet,docker,fastapi,django-ninja}/**" --filter "!./projects/proxy-scalar-com/**"'
export NUGET_PACKAGES="${PWD}/.nuget/packages"

# Shard configuration (from matrix)
SHARD_INDEX=2
SHARD_TOTAL=3

echo "=== Installing dependencies ==="
pnpm install

echo "=== Building packages ==="
pnpm turbo $TURBO_FLAGS --filter './packages/**' build

echo "=== Starting test servers ==="
pnpm script run test-servers &
TEST_SERVER_PID=$!

# Wait for test servers to be ready on ports 5051 and 5052
echo "=== Waiting for test servers to be ready ==="
pnpm script wait -p 5051 5052 || true

echo "=== Running tests for shard $SHARD_INDEX of $SHARD_TOTAL ==="

# Find all packages with test scripts
dirs=()
for dir in packages/*/; do
  if grep -q '"test"' "${dir}package.json" 2>/dev/null; then
    dirs+=("$dir")
  fi
done

# Filter packages for this shard
args=()
for i in "${!dirs[@]}"; do
  if (( i % SHARD_TOTAL == SHARD_INDEX - 1 )); then
    args+=(--filter "./${dirs[$i]%/}")
  fi
done

# Run tests
if [ ${#args[@]} -eq 0 ]; then
  echo "No packages assigned to this shard, skipping."
  kill $TEST_SERVER_PID 2>/dev/null || true
  exit 0
fi

# Run turbo test with all filtered packages
# Use || true to ensure all tests run even if some fail
TEST_FAILED=0
pnpm turbo "${args[@]}" test || TEST_FAILED=1

# Cleanup test servers
kill $TEST_SERVER_PID 2>/dev/null || true

# Exit with failure if tests failed
if [ "${TEST_FAILED}" = "1" ]; then
  exit 1
fi

exit 0