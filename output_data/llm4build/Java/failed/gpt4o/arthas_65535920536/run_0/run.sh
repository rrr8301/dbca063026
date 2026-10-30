#!/bin/bash

# Clone the repository (simulating actions/checkout)
# Assuming the repository is already copied in the Dockerfile

# Build with Maven
mvn -V -ntp clean install -P full verify || true

# Ensure all tests are executed, even if some fail
mvn test || true