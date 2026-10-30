#!/usr/bin/env bash
set -e

cd /app

echo "Starting Maven build..."
./mvnw -B -ff -ntp verify

echo ""
echo "FINAL_STATUS = SUCCESS"
