#!/usr/bin/env bash
set -e

cd /app

mvn -B clean test

if [ $? -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = FAIL"
fi
