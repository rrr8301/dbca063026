#!/usr/bin/env bash
set -e

# Start Redis server in the background
redis-server --daemonize yes --port 6379

# Download and run Nacos
mkdir -p /tmp/nacos
cd /tmp/nacos

# Download Nacos binary
wget -q https://github.com/alibaba/nacos/releases/download/2.4.2/nacos-server-2.4.2.tar.gz
tar -xzf nacos-server-2.4.2.tar.gz

# Set up environment for Nacos
export MODE=standalone
export SPRING_SECURITY_ENABLED=false

# Start Nacos in the background
cd /tmp/nacos/nacos
./bin/startup.sh -m standalone &
NACOS_PID=$!

# Wait for services to be ready
sleep 10

# Wait for Redis to be ready
for i in {1..30}; do
  if redis-cli ping &> /dev/null; then
    echo "Redis is ready"
    break
  fi
  sleep 1
done

# Wait for Nacos to be ready
for i in {1..60}; do
  if curl -f http://localhost:8848/nacos &> /dev/null; then
    echo "Nacos is ready"
    break
  fi
  sleep 1
done

# Run the Maven test
cd /app
./mvnw -T 4C clean test \
  -P args-for-client-test \
  -Dspring-boot.version=2.7.18 \
  -D spring-framework-bom.version=5.3.31 \
  -e -B \
  -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn

TEST_RESULT=$?

# Clean up
kill $NACOS_PID 2>/dev/null || true

if [ $TEST_RESULT -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
  exit 0
else
  echo "FINAL_STATUS = FAIL"
  exit 1
fi
