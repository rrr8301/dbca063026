#!/bin/bash

# Activate environment variables if needed
export UV_PYTHON_DOWNLOADS=never

# Install project dependencies
pnpm install

# Build packages
pnpm turbo $TURBO_FLAGS --filter './packages/**' build

# Start test servers
pnpm script run test-servers & pnpm script wait -p 5051 5052

# Run tests
dirs=()
for dir in packages/*/; do
  if grep -q '"test"' "${dir}package.json" 2>/dev/null; then
    dirs+=("$dir")
  fi
done
args=()
for i in "${!dirs[@]}"; do
  if (( i % 3 == 2 - 1 )); then
    args+=(--filter "./${dirs[$i]%/}")
  fi
done
if [ ${#args[@]} -eq 0 ]; then
  echo "No packages assigned to this shard, skipping."
  exit 0
fi
pnpm turbo "${args[@]}" test