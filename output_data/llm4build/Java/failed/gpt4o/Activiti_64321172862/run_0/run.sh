#!/bin/bash

# Set Maven options
export MAVEN_CLI_OPTS="--show-version --no-transfer-progress --settings settings.xml"

# Build and test with Maven
mvn verify $MAVEN_CLI_OPTS -Drat.skip=true -Dlicense.skip=true

# Echo longest tests run
find . -name TEST-*.xml -exec grep -h testcase {} \; | awk -F '"' '{printf("%s#%s() - %.3f s\n", $4, $2, $6); }' | sort -n -k 3 | tail -20