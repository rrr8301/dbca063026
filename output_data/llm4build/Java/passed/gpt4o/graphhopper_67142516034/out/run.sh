#!/bin/bash

# Activate environment variables if needed (none in this case)

# Install project dependencies
# Maven will handle dependencies specified in pom.xml

# Run tests
# Ensure all tests are executed, even if some fail
mvn -B clean test || true