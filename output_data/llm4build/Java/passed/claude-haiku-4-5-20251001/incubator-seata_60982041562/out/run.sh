#!/bin/bash

set -e

# Start Redis service
echo "Starting Redis server..."
service redis-server start
sleep 2

# Start Nacos server
echo "Starting Nacos server..."
export MODE=standalone
export SPRING_SECURITY_ENABLED=false
cd /opt/nacos/nacos/bin
bash startup.sh -m standalone > /tmp/nacos.log 2>&1 &
NACOS_PID=$!
sleep 30

# Verify Nacos is running
echo "Verifying Nacos health..."
for i in {1..30}; do
    if curl -f http://localhost:8848/nacos > /dev/null 2>&1; then
        echo "Nacos is healthy"
        break
    fi
    echo "Waiting for Nacos... ($i/30)"
    sleep 1
done

# Navigate to workspace
cd /workspace

# Run Maven tests
echo "Running Maven tests..."
mvn -T 4C clean test \
    -P args-for-client-test \
    -Dspring-boot.version=2.7.18 \
    -Dspring-framework-bom.version=5.3.31 \
    -e \
    -B \
    -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn \
    -Drat.skip=true \
    -Dlicense.skip=true

echo "Tests completed successfully!"