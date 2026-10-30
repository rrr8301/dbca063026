#!/bin/bash

# Activate environment variables
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"

# Install project dependencies and run tests
mvn -T 4 --batch-mode -Djava.awt.headless=true verify -P enableTests,enableCheckStyle -Drat.skip=true -Dlicense.skip=true