#!/bin/bash

# Activate environment variables
export JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Install project dependencies and build
./mvnw -B -ff -ntp verify

# Extract project Maven version
version=$(./mvnw org.apache.maven.plugins:maven-help-plugin:3.5.1:evaluate -DforceStdout -Dexpression=project.version -q)
echo "Project version: $version"

# Verify Android SDK Compatibility
./mvnw -B -q -ff -ntp -DskipTests animal-sniffer:check

# Generate code coverage
./mvnw -B -q -ff -ntp test jacoco:report

# Note: Deployment and code coverage publishing steps are skipped