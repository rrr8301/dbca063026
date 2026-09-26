#!/bin/bash

# Activate environment variables if needed (none in this case)

# Set Maven compiler properties to use Java 17
export MAVEN_OPTS="-Djava.version=17 -Dmaven.compiler.source=17 -Dmaven.compiler.target=17"

# Install project dependencies and build
mvn -Ddoclint=all --show-version --batch-mode --no-transfer-progress clean install

# Run tests
mvn test || true  # Ensure all tests run even if some fail