#!/bin/bash

# Activate Java environment
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Install project dependencies and run tests
./mvnw clean install -T1C -B -ntp -fae

# Ensure all test cases are executed, even if some fail
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
  echo "Some tests failed. Check the logs for details."
fi

exit $EXIT_CODE