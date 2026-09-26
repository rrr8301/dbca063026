#!/bin/bash

# Navigate to the app directory
cd /app

# Install project dependencies
mvn -B -ntp -Dtoolchain.skip install -U -DskipTests=true -Drat.skip=true -Dlicense.skip=true -f pom.xml

# Run tests
mvn -B -ntp -P!standard-with-extra-repos -Dtoolchain.skip verify -U -Dmaven.javadoc.skip=true -Dsurefire.toolchain.version=11 -Drat.skip=true -Dlicense.skip=true -f pom.xml

# Print Surefire reports if tests fail
if [ $? -ne 0 ]; then
    ./util/print_surefire_reports.sh
fi