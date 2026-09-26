#!/bin/bash

# Activate environment variables if needed (none specified)

# Install project dependencies
./gradlew build

# Run tests
./gradlew test || true  # Ensure all tests run even if some fail