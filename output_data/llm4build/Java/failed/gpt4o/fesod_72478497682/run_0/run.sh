#!/bin/bash

# Set Java Home
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Run Maven tests
mvn clean package -B -Dmaven.test.skip=false -pl fesod-common,fesod-shaded,fesod-sheet,fesod-examples/fesod-sheet-examples -Drat.skip=true -Dlicense.skip=true