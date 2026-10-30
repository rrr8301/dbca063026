#!/bin/bash

# Activate any necessary environments (none specified)

# Install project dependencies (none specified beyond Maven)
# Build the project using Maven
mvn -V -ntp clean install -P full verify

# Run tests
# Ensure all tests are executed, even if some fail
mvn test