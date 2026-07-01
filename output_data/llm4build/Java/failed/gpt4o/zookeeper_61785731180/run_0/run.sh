#!/bin/bash

# Show the first log message
git log -n1

# Build with Maven
mvn -B -V -e -ntp "-Dstyle.color=always" -Pfull-build verify -Dsurefire-forkcount=1 -DskipCppUnit -Dsurefire.rerunFailingTestsCount=5 -Drat.skip=true -Dlicense.skip=true