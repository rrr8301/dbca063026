#!/bin/bash

# Activate environment variables if needed (none in this case)

# Install project dependencies and build
mvn --errors --show-version --batch-mode --no-transfer-progress -Ddoclint=all

# Run tests
mvn test || true  # Ensure all tests run even if some fail