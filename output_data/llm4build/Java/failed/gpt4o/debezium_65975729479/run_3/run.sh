#!/bin/bash

# Activate environment (if any)

# Install project dependencies
# Assuming Maven will handle dependencies
mvn clean install -Drat.skip=true -Dlicense.skip=true

# Run tests or build steps
echo "Setting up job"
echo "Building MySQL 8.0 - mysql-ci"
echo "Post build steps for MySQL 8.0 - mysql-ci"
echo "Post checkout steps"
echo "Completing job"