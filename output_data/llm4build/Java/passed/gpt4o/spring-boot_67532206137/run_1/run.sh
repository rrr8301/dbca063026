#!/bin/bash

# Clean the /app directory before cloning
rm -rf /app/*

# Clone the repository
git clone https://github.com/spring-projects/spring-boot.git /app
cd /app

# Set Java Home
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

# Build the project
./gradlew build

# Run tests
./gradlew test  # Removed the `|| true` to ensure all tests are run and failures are not ignored