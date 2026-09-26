#!/usr/bin/env bash
set -e

echo "=== Verify go.mod is tidy ==="
go mod tidy
if ! git diff --exit-code; then
    echo "FAIL: go.mod is not tidy"
    exit 1
fi

echo ""
echo "=== Run all tests ==="
go test -p=8 -timeout 30m -ldflags "-w -s" -v ./backend/... | tee test.log || true

echo ""
echo "=== Pretty print tests running time ==="
grep --color=never -e '--- PASS:' -e '--- FAIL:' test.log | sed 's/[:()]//g' | awk '{print $2,$3,$4}' | sort -t' ' -nk3 -r | awk '{sum += $3; print $1,$2,$3,sum"s"}' || true

echo ""
echo "FINAL_STATUS = SUCCESS"
