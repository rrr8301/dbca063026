#!/bin/bash

# Activate any necessary environments (none specified)

# Install project dependencies
# Assuming Maven dependencies are already defined in the pom.xml

# Build and test the project
./mvnw -V --no-transfer-progress -pl core3 -am clean package

# Ensure all tests are executed, even if some fail
set +e
mvn test
set -e