#!/bin/bash

# Activate environment variables
export PW_MAX_RETRIES=3
export BROWSER=firefox

# Download drivers
bash scripts/download_driver.sh

# Build & Install
mvn -B install -D skipTests --no-transfer-progress

# Install browsers
mvn exec:java -e -D exec.mainClass=com.microsoft.playwright.CLI -D exec.args="install --with-deps" -f playwright/pom.xml --no-transfer-progress

# Run tests
mvn test --no-transfer-progress --fail-at-end

# Test Spring Boot Starter
cd tools/test-spring-boot-starter
mvn package -D skipTests --no-transfer-progress
java -jar target/test-spring-boot*.jar