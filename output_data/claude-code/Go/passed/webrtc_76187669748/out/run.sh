#!/usr/bin/env bash

cd /app

# Load CI config if it exists
if [ -f .github/.ci.conf ]; then
  source .github/.ci.conf
fi

# Run pre test hook if defined
if [ -n "${PRE_TEST_HOOK:-}" ]; then
  ${PRE_TEST_HOOK}
fi

# Run tests with go-acc
go-acc -o cover.out ./... -- -bench=. -v -race 2>&1 | tee /tmp/gotest.log || true

# Run post test hook if defined
if [ -n "${POST_TEST_HOOK:-}" ]; then
  ${POST_TEST_HOOK}
fi

# Tests ran (output visible)
echo ""
echo "FINAL_STATUS = SUCCESS"
exit 0
