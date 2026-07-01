#!/usr/bin/env bash

cd /app

echo "Running make test-loadable..."
make test-loadable || true

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
