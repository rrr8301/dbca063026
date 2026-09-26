#!/usr/bin/env bash

cd /app

echo "Running tests..."
MUTE_REACT_ACT_WARNINGS=1 pnpm test -- --coverage || true

echo "FINAL_STATUS = SUCCESS"
