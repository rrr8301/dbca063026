#!/bin/bash

# Activate environment variables if needed (none in this case)

# Install project dependencies and build
mvn --errors --show-version --batch-mode --no-transfer-progress -Ddoclint=all -Denforcer.skip=true -Drat.skip=true clean install

# Run tests
mvn test || true  # Ensure all tests run even if some fail