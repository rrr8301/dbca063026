#!/usr/bin/env bash
set -e

echo "=== Verifying go.mod is tidy ==="
go mod tidy
git diff --exit-code

echo "=== Running all tests ==="
go test -p=8 -timeout 30m -ldflags "-w -s" -v ./backend/... | tee test.log
TEST_EXIT_CODE=${PIPESTATUS[0]}

if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo ""
    echo "=== Pretty printing test times ==="
    grep --color=never -e '--- PASS:' -e '--- FAIL:' test.log | sed 's/[:()]//g' | awk '{print $2,$3,$4}' | sort -t' ' -nk3 -r | awk '{sum += $3; print $1,$2,$3,sum"s"}' || true
fi

exit $TEST_EXIT_CODE
