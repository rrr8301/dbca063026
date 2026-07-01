#!/bin/bash

set -e

# Enable error handling: continue on test failures but track them
FAILED=0

# Clone repository if not already present
if [ ! -d "src" ]; then
    git clone https://github.com/tailscale/tailscale.git src
fi

cd src

# Export environment variables
export GOARCH=amd64
export GOMODCACHE=/workspace/gomodcache
export CMD_GO_USE_GIT_HASH=true
export PATH="$PWD/tool:$PATH"

# Ensure go mod cache directory exists
mkdir -p "$GOMODCACHE"

echo "=== Building all packages ==="
if ! ./tool/go build ./...; then
    echo "Build failed"
    FAILED=1
fi

echo "=== Building test wrapper ==="
if ! ./tool/go build -o /tmp/testwrapper ./cmd/testwrapper; then
    echo "Test wrapper build failed"
    FAILED=1
fi

echo "=== Running tests ==="
if ! NOBASHDEBUG=true NOPWSHDEBUG=true /tmp/testwrapper ./...; then
    echo "Tests failed"
    FAILED=1
fi

echo "=== Running benchmarks ==="
if ! ./tool/go test -bench=. -benchtime=1x -run=^$ $(for x in $(git grep -l "^func Benchmark" | xargs dirname | sort | uniq); do echo "./$x"; done); then
    echo "Benchmarks failed"
    FAILED=1
fi

echo "=== Checking that no tracked files changed ==="
if ! git diff --no-ext-diff --name-only --exit-code; then
    echo "Build/test modified the files above."
    FAILED=1
fi

echo "=== Checking that no new files were added ==="
if git ls-files --others --exclude-standard --directory --no-empty-directory --error-unmatch -- ':/*' 2>/dev/null; then
    echo "Build/test created untracked files in the repo (file names above)."
    FAILED=1
fi

echo "=== Tidying cache ==="
find $(go env GOCACHE) -type f -mmin +90 -delete || true

if [ $FAILED -ne 0 ]; then
    echo "Some tests or checks failed"
    exit 1
fi

echo "=== All tests passed ==="
exit 0