#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Build with Maven
mvn -V -ntp clean install -P full verify

# Run all tests
mvn test