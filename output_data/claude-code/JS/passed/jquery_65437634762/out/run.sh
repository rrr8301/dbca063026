#!/bin/sh
set -e

cd /app

npm run test:browserless 2>&1

echo "FINAL_STATUS = SUCCESS"
