#!/bin/bash

set -e

# Set environment variables
export PW_MAX_RETRIES=3
export BROWSER=firefox

echo "=========================================="
echo "Starting Playwright Java Build & Test"
echo "=========================================="

# Verify Java installation
echo "Java version:"
java -version

# Verify Maven installation
echo "Maven version:"
mvn -version

# Download drivers
echo "Downloading drivers..."
if [ -f "scripts/download_driver.sh" ]; then
    bash scripts/download_driver.sh
else
    echo "Warning: scripts/download_driver.sh not found, skipping driver download"
fi

# Build & Install
echo "Building and installing project..."
mvn -B install -DskipTests --no-transfer-progress

# Install browsers
echo "Installing Playwright browsers..."
mvn exec:java -e -Dexec.mainClass=com.microsoft.playwright.CLI -Dexec.args="install --with-deps" -f playwright/pom.xml --no-transfer-progress

# Run tests
echo "Running tests..."
mvn test --no-transfer-progress --fail-at-end || TEST_FAILED=1

# Test Spring Boot Starter
echo "Testing Spring Boot Starter..."
cd tools/test-spring-boot-starter
mvn package -DskipTests --no-transfer-progress
java -jar target/test-spring-boot*.jar || SPRING_TEST_FAILED=1

# Report results
echo "=========================================="
if [ -z "$TEST_FAILED" ] && [ -z "$SPRING_TEST_FAILED" ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed!"
    exit 1
fi