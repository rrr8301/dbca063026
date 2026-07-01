#!/usr/bin/env bash
set -e

cd /app

echo "Running: GOTRACEBACK=all make testnocgo"
GOTRACEBACK=all make testnocgo

echo ""
echo "FINAL_STATUS = SUCCESS"
