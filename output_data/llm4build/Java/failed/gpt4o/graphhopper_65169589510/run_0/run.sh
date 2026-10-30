#!/bin/bash

# Activate any necessary environments (none in this case)

# Install project dependencies and build
mvn -B clean install

# Run tests
mvn -B test || true

# Ensure all tests are executed, even if some fail