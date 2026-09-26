#!/bin/bash

# Activate environment
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Install project dependencies and run tests
mvn clean install -T1C -B -ntp -fae -Drat.skip=true -Dlicense.skip=true