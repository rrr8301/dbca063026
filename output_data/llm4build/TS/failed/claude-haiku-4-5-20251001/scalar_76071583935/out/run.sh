#!/bin/bash
set -e

# Extract Node.js version from .nvmrc
NODE_VERSION=$(cat .nvmrc | tr -d 'v')
echo "Using Node.js version: $NODE_VERSION"

# Install pnpm globally (if not already installed)
npm install -g pnpm

# Install project dependencies
echo "Installing dependencies..."
pnpm install --frozen-lockfile

# Build packages
echo "Building packages..."
pnpm turbo --filter './packages/**' build

# Check built declaration alias imports (only on shard 1)
SHARD_INDEX=${SHARD_INDEX:-1}
SHARD_TOTAL=${SHARD_TOTAL:-3}

if [ "$SHARD_INDEX" -eq 1 ]; then
    echo "Running lint check for declaration alias imports..."
    pnpm lint:check:dist-dts-aliases
fi

# Fix invalid Go version in go.mod before starting servers
if [ -f "projects/proxy-scalar-com/go.mod" ]; then
    echo "Fixing Go version in go.mod..."
    sed -i 's/go 1\.26\.2/go 1.23/g' projects/proxy-scalar-com/go.mod
fi

# Start test servers in background
echo "Starting test servers..."
pnpm script run test-servers & 
TEST_SERVERS_PID=$!
pnpm script wait -p 5051 5052
echo "Test servers started (PID: $TEST_SERVERS_PID)"

# Run sharded tests
echo "Running tests for shard $SHARD_INDEX of $SHARD_TOTAL..."

# Build list of directories with test scripts
dirs=()
for dir in packages/*/; do
    if grep -q '"test"' "${dir}package.json" 2>/dev/null; then
        dirs+=("$dir")
    fi
done

# Determine which packages to test based on shard
args=()
for i in "${!dirs[@]}"; do
    if (( i % SHARD_TOTAL == SHARD_INDEX - 1 )); then
        args+=(--filter "./${dirs[$i]%/}")
    fi
done

# Run tests
if [ ${#args[@]} -eq 0 ]; then
    echo "No packages assigned to this shard, skipping."
    kill $TEST_SERVERS_PID 2>/dev/null || true
    exit 0
fi

echo "Running: pnpm turbo ${args[@]} test"
pnpm turbo "${args[@]}" test

# Cleanup
kill $TEST_SERVERS_PID 2>/dev/null || true