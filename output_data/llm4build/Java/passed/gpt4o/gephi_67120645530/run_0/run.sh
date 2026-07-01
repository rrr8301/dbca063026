#!/bin/bash

# Clone the repository (assuming the repo URL is provided as an argument)
# git clone <repository-url> /app

# Navigate to the application directory
cd /app

# Build the project with Maven
mvn -T 4 --batch-mode -Djava.awt.headless=true verify -P enableTests,enableCheckStyle

# Run tests (assuming tests are part of the Maven build)
# Ensure all tests are executed, even if some fail
mvn test || true