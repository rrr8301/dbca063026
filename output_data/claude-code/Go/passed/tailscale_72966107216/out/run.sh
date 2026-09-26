#!/usr/bin/env bash
set -e

cd /app

echo "=== Building all packages ==="
./tool/go build ./...

echo "=== Building variant CLIs ==="
./build_dist.sh --extra-small ./cmd/tailscaled
./build_dist.sh --box ./cmd/tailscaled
./build_dist.sh --extra-small --box ./cmd/tailscaled
rm -f tailscaled

echo "=== Building test wrapper ==="
./tool/go build -o /tmp/testwrapper ./cmd/testwrapper

echo "=== Running tests ==="
NOBASHDEBUG=true NOPWSHDEBUG=true PATH=$PWD/tool:$PATH /tmp/testwrapper ./...

echo "=== Running benchmarks ==="
./tool/go test -bench=. -benchtime=1x -run=^$ $(for x in $(git grep -l "^func Benchmark" | xargs dirname | sort | uniq); do echo "./$x"; done) || true

echo "=== Checking file integrity ==="
git diff --no-ext-diff --name-only --exit-code || (echo "Build/test modified the files above."; exit 1)

if git ls-files --others --exclude-standard --directory --no-empty-directory --error-unmatch -- ':/*'
then
  echo "Build/test created untracked files in the repo (file names above)."
  exit 1
fi

echo ""
echo "FINAL_STATUS = SUCCESS"
