#!/bin/bash

# Verify go.mod is tidy
go mod tidy
git diff --exit-code

# Run all tests
go test -p=8 -timeout 30m -ldflags "-w -s" -v ./backend/... | tee test.log
exit ${PIPESTATUS[0]}