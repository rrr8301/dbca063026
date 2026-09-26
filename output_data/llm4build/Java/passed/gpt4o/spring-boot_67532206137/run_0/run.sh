#!/bin/bash

# Clone the repository
git clone https://github.com/spring-projects/spring-boot.git /app
cd /app

# Set Java Home
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

# Build the project
./gradlew build

# Run tests
./gradlew test || true  # Ensure all tests run even if some fail