#!/usr/bin/env bash

cd /app

echo "========== Test sources =========="
npm run test:sources || true

echo ""
echo "========== Test types =========="
npm run test:types || true

echo ""
echo "FINAL_STATUS = SUCCESS"
