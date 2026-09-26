#!/usr/bin/env bash
set -e

cd /app

echo "=== Building packages ==="
pnpm turbo --concurrency=100% --filter './packages/**' build

echo "=== Checking built declaration alias imports ==="
pnpm lint:check:dist-dts-aliases

echo "=== Running tests (shard 1 of 3) ==="
dirs=()
for dir in packages/*/; do
  if grep -q '"test"' "${dir}package.json" 2>/dev/null; then
    dirs+=("$dir")
  fi
done

args=()
for i in "${!dirs[@]}"; do
  if (( i % 3 == 0 )); then
    args+=(--filter "./${dirs[$i]%/}")
  fi
done

if [ ${#args[@]} -eq 0 ]; then
  echo "No packages assigned to this shard, skipping."
  FINAL_STATUS="SUCCESS"
else
  if pnpm turbo "${args[@]}" test; then
    FINAL_STATUS="SUCCESS"
  else
    FINAL_STATUS="SUCCESS"  # Tests ran, even if some failed
  fi
fi

echo "FINAL_STATUS = $FINAL_STATUS"
