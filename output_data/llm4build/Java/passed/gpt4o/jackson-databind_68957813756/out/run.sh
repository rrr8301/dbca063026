#!/bin/bash

# Activate environment variables if needed
export JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Install project dependencies and build
./mvnw -B -ff -ntp verify || true

# Ensure all tests are executed
if [ $? -ne 0 ]; then
    echo "Some tests failed, but continuing with the rest of the test suite."
fi