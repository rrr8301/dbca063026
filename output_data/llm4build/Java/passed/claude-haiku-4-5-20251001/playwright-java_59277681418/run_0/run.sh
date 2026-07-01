#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Download drivers
echo "Downloading drivers..."
bash scripts/download_driver.sh

# Build & Install (skip tests)
echo "Building and installing project..."
mvn -B install -DskipTests --no-transfer-progress -Drat.skip=true -Dlicense.skip=true

# Install Playwright browsers
echo "Installing Playwright browsers..."
mvn exec:java -e -Dexec.mainClass=com.microsoft.playwright.CLI -Dexec.args="install --with-deps" -f playwright/pom.xml --no-transfer-progress -Drat.skip=true -Dlicense.skip=true

# Run Maven tests
echo "Running Maven tests..."
export BROWSER=chromium
mvn test --no-transfer-progress --fail-at-end -Drat.skip=true -Dlicense.skip=true

# Test Spring Boot Starter
echo "Testing Spring Boot Starter..."
cd tools/test-spring-boot-starter
mvn package -DskipTests --no-transfer-progress -Drat.skip=true -Dlicense.skip=true
java -jar target/test-spring-boot*.jar

echo "All tests completed successfully!"