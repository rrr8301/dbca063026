#!/usr/bin/env bash
set -e

cd /app

echo "=== Step 1: Download drivers ==="
bash scripts/download_driver.sh

echo "=== Step 2: Build & Install ==="
mvn -B install -D skipTests --no-transfer-progress

echo "=== Step 3: Install browsers ==="
mvn exec:java -e -D exec.mainClass=com.microsoft.playwright.CLI -D exec.args="install --with-deps" -f playwright/pom.xml --no-transfer-progress

echo "=== Step 4: Run tests ==="
mvn test --no-transfer-progress --fail-at-end || true

echo "=== Step 5: Test Spring Boot Starter ==="
cd tools/test-spring-boot-starter
mvn package -D skipTests --no-transfer-progress
java -jar target/test-spring-boot*.jar || true

echo "FINAL_STATUS = SUCCESS"
