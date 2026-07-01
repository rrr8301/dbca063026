#!/bin/bash

# Show the first log message
git log -n1

# Install C dependencies (already installed in Dockerfile, but ensure they are up-to-date)
sudo apt-get update
sudo apt-get install -y libcppunit-dev libsasl2-dev

# Build with Maven
mvn -B -V -e -ntp "-Dstyle.color=always" -Pfull-build verify -Dsurefire-forkcount=1 -DskipCppUnit -Dsurefire.rerunFailingTestsCount=5

# Ensure all tests are executed, even if some fail
EXIT_CODE=0
mvn test || EXIT_CODE=$?
exit $EXIT_CODE