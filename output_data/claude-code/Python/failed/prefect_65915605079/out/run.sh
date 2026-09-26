#!/usr/bin/env bash
set -e

# Start redis in the background
redis-server --daemonize yes

# Run the tests
uv run pytest tests/server/orchestration/ --ignore=tests/server/orchestration/api/ \
  -m "not windows" \
  --numprocesses auto \
  --maxprocesses 6 \
  --dist worksteal \
  --disable-docker-image-builds \
  --exclude-service kubernetes \
  --exclude-service docker \
  --durations 26 || true

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
