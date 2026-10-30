#!/bin/bash

# Activate environment variables if needed

# Install project dependencies
# No additional dependencies specified

# Run Maven build
mvn -B -V -e -ntp "-Dstyle.color=always" -Pfull-build verify -Dsurefire-forkcount=1 -Dsurefire.rerunFailingTestsCount=5 -Drat.skip=true -Dlicense.skip=true