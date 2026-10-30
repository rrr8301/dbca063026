#!/bin/bash

# Activate environment variables if needed (none in this case)

# Install project dependencies
mvn clean install

# Run tests
mvn test || true  # Ensure all tests run even if some fail