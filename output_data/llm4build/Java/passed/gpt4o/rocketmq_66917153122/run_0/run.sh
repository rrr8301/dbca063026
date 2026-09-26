#!/bin/bash

# Activate any necessary environments (none in this case)

# Install project dependencies
# Assuming Maven dependencies are defined in pom.xml
mvn clean install

# Run tests
# Ensure all tests are executed, even if some fail
mvn test || true