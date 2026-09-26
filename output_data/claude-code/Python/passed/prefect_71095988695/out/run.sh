#!/usr/bin/env bash
set -e

cd /app

echo "Running Server Tests with Python 3.10 and SQLite..."

uv run pytest tests/server/ tests/events/server \
  --ignore=tests/server/database/ \
  --ignore=tests/server/orchestration/ \
  -m "not windows" \
  --numprocesses auto \
  --maxprocesses 6 \
  --dist worksteal \
  --disable-docker-image-builds \
  --exclude-service kubernetes \
  --exclude-service docker \
  --durations 26

if [ $? -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = FAIL"
  exit 1
fi
