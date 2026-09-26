#!/usr/bin/env bash
set -e

# Start Redis service in background
redis-server --daemonize yes --port 6379 2>/dev/null || true

# Run Maven test
cd /app
./mvnw -T 4C clean test \
    -P args-for-client-test \
    -Dspring-boot.version=2.6.15 \
    -Dspring-framework-bom.version=5.3.27 \
    -e -B \
    -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn

echo "FINAL_STATUS = SUCCESS"
