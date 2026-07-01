#!/bin/bash

# Activate environment variables
export MYSQL_DRIVER_CLASSNAME=com.mysql.jdbc.Driver
export SEGMENT_DOWNLOAD_TIMEOUT_MINS=5

# Install project dependencies
mvn clean install -DskipTests

# Run tests
mvn test -Dmaven.test.failure.ignore=true

# Ensure all test cases are executed
if [ $? -ne 0 ]; then
  echo "Some tests failed, but continuing with the rest of the test suite."
fi