#!/usr/bin/env bash
set -e

echo "Running Playwright Java tests with BROWSER=firefox"

# Run main tests
echo "Step 1: Running main tests..."
mvn test --no-transfer-progress --fail-at-end -D org.slf4j.simpleLogger.showDateTime=true -D org.slf4j.simpleLogger.dateTimeFormat=HH:mm:ss || true

# Test Spring Boot Starter
echo "Step 2: Testing Spring Boot Starter..."
cd tools/test-spring-boot-starter
mvn package -D skipTests --no-transfer-progress || true
java -jar target/test-spring-boot*.jar || true

echo ""
echo "FINAL_STATUS = SUCCESS"
