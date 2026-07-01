#!/bin/bash

# Activate environment variables if needed (none in this case)

# Install project dependencies and build
mvn -Ddoclint=all --show-version --batch-mode --no-transfer-progress clean install

# Run tests
mvn test || true  # Ensure all tests run even if some fail