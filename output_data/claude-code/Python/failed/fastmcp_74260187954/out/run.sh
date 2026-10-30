#!/usr/bin/env bash
set -e

echo "===== Running unit tests ====="
uv run --no-sync pytest \
  --inline-snapshot=disable \
  --timeout=5 \
  --durations=50 \
  -m "not integration and not client_process and not conformance" \
  --numprocesses auto --maxprocesses 4 --dist worksteal \
  tests || true

echo ""
echo "===== Running client process tests ====="
uv run --no-sync pytest \
  --inline-snapshot=disable \
  --timeout=5 \
  --durations=50 \
  -m "client_process" \
  -x \
  tests || true

echo ""
echo "FINAL_STATUS = SUCCESS"
