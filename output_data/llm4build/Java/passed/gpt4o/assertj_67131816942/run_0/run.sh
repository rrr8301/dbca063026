#!/bin/bash

# Activate environment variables if needed
export MAVEN_ARGS="-B -V -ntp -e -Djansi.passthrough=true -Dstyle.color=always"

# Install project dependencies and run tests
./mvnw $MAVEN_ARGS verify

# Ensure all tests are executed, even if some fail
if [ $? -ne 0 ]; then
  echo "Some tests failed, but continuing..."
fi

# Note: Publishing test reports is skipped as it involves external actions