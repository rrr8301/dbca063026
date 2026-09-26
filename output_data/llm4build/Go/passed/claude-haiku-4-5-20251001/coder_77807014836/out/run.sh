#!/usr/bin/env bash
set -euo pipefail

# Run Go tests with PostgreSQL
go test -v -parallel 8 -count=1 ./...