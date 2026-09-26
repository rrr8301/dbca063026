#!/usr/bin/env bash
set -e

cd /app

echo "=== Enabling IPv6 ==="
sysctl -w net.ipv6.conf.all.disable_ipv6=0 2>/dev/null || true
sysctl -w net.ipv6.conf.default.disable_ipv6=0 2>/dev/null || true
sysctl -w net.ipv6.conf.lo.disable_ipv6=0 2>/dev/null || true

echo "=== Verifying code generation ==="
make verify-generate

echo "=== Running linter ==="
make lint

echo "=== Building binary ==="
make build

echo "=== Running tests with coverage ==="
COVER=true make test

echo "=== Test run completed ==="
echo "FINAL_STATUS = SUCCESS"
