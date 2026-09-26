#!/bin/bash

# Activate any necessary environments (none needed for Java)

# Install project dependencies and build the project
mvn clean verify javadoc:jar

# Run tests
# Ensure all tests are executed, even if some fail
mvn test