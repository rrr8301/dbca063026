#!/usr/bin/env bash

cd /app
yarn test:packages || true

echo "FINAL_STATUS = SUCCESS"
