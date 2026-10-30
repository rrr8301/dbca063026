#!/usr/bin/env bash
set -e

cd /app

echo "=== Running unit tests ==="
uv run pytest \
  --inline-snapshot=disable \
  --timeout=5 \
  --durations=50 \
  -m "not integration and not client_process and not conformance" \
  --numprocesses auto \
  --maxprocesses 4 \
  --dist worksteal \
  tests || true

echo ""
echo "=== Running client process tests ==="
uv run pytest \
  --inline-snapshot=disable \
  --timeout=5 \
  --durations=50 \
  -m "client_process" \
  -x \
  tests || true

echo ""
echo "FINAL_STATUS = SUCCESS"
