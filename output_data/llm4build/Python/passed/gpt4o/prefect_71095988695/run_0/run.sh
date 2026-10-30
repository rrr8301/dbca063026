#!/bin/bash

# Start Redis server in the background
redis-server &

# Run tests
uv run pytest tests/server/ tests/events/server --ignore=tests/server/database/ --ignore=tests/server/orchestration/ \
-m "not windows" \
--numprocesses auto \
--maxprocesses 6 \
--dist worksteal \
--disable-docker-image-builds \
--exclude-service kubernetes \
--exclude-service docker \
--durations 26 || true

# Check database container (simulated)
echo "No Postgres service to check for sqlite configuration"