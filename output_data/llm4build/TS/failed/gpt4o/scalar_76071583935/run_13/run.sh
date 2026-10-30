#!/bin/bash

# Activate environments
export PATH=$PATH:/usr/local/go/bin

# Ensure SHARD_TOTAL and SHARD_INDEX are set
if [ -z "$SHARD_TOTAL" ] || [ -z "$SHARD_INDEX" ]; then
  echo "SHARD_TOTAL and SHARD_INDEX must be set"
  exit 1
fi

# Install project dependencies
# Adding --loglevel=error to reduce verbosity and focus on errors
pnpm install --no-frozen-lockfile --loglevel=error || \
    (echo "Retrying pnpm install without shamefully-hoist" && pnpm install --no-frozen-lockfile --loglevel=error --shamefully-hoist)

# Build packages
pnpm turbo $TURBO_FLAGS --filter './packages/**' build

# Check built declaration alias imports
if [ "$SHARD_INDEX" == "1" ]; then
  pnpm lint:check:dist-dts-aliases
fi

# Setup Go
if [ -f "go.mod" ]; then
  go mod download
else
  echo "No go.mod file found, skipping Go module download."
fi

# Start test servers
pnpm run test-servers & pnpm wait-on -p 5051 5052

# Run tests
dirs=()
for dir in packages/*/; do
  if grep -q '"test"' "${dir}package.json" 2>/dev/null; then
    dirs+=("$dir")
  fi
done
args=()
for i in "${!dirs[@]}"; do
  if (( i % SHARD_TOTAL == SHARD_INDEX - 1 )); then
    args+=(--filter "./${dirs[$i]%/}")
  fi
done
if [ ${#args[@]} -eq 0 ]; then
  echo "No packages assigned to this shard, skipping."
  exit 0
fi
pnpm turbo "${args[@]}" test