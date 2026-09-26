#!/usr/bin/env bash

set -e

cd /app/tests

echo "Running integration tests..."
go test ./integration/... -timeout 30m -coverpkg=../... -coverprofile=integration-profile.out -covermode=atomic

echo "FINAL_STATUS = SUCCESS"
