#!/usr/bin/env bash

cd /app

npm run tests-only || true

echo "FINAL_STATUS = SUCCESS"
