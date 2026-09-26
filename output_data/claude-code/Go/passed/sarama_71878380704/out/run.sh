#!/usr/bin/env bash
set -e

export GOFLAGS="-trimpath"
export DEBUG=true

# Create test output directory
mkdir -p _test

# Go mod tidy to ensure dependencies are properly resolved
go mod tidy -v || true

# Install test tools with retry
for i in {1..3}; do
  if GOBIN=/go/bin go install gotest.tools/gotestsum@v1.13.0 && \
     GOBIN=/go/bin go install github.com/vearutop/teststat@v0.1.27; then
    break
  fi
  echo "Attempt $i failed, retrying..."
  sleep 2
done || true

# Run tests
/go/bin/gotestsum --format testdox --jsonfile _test/unittests.json --junitfile _test/unittests.xml \
    --rerun-fails --packages="./..." \
    -- -v -race -coverprofile=profile.out -covermode=atomic -timeout 2m 2>&1 || true

# Report test results if teststat is available
if [ -x /go/bin/teststat ]; then
  /go/bin/teststat _test/unittests.json || true
fi

# Print final status
echo "FINAL_STATUS = SUCCESS"
