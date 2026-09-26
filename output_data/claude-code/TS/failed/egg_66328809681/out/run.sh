#!/usr/bin/env bash

set -e

echo "=== Running lint ==="
ut run lint

echo "=== Running typecheck ==="
ut run typecheck

echo "=== Running format check ==="
ut run fmtcheck

echo "=== Running build ==="
ut run build

echo "=== Running site build ==="
ut run site:build

echo "FINAL_STATUS = SUCCESS"
