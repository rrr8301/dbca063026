#!/bin/bash

# Start Redis container
docker run --name "redis" --detach --publish 6379:6379 redis:latest

# Run tests
uv run pytest tests/server/orchestration/ \
  -m "not windows" \
  --numprocesses auto \
  --maxprocesses 6 \
  --dist worksteal \
  --disable-docker-image-builds \
  --exclude-service kubernetes \
  --exclude-service docker \
  --durations 26

# Check database container logs
docker container inspect postgres && docker container logs postgres || echo "Ignoring bad exit code"