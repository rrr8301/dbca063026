#!/bin/bash

# Build with Maven
mvn -V -ntp clean install -P full verify

# Run all tests
mvn test