#!/bin/bash

# Activate environments
export JAVA_HOME=/opt/jdk8u302-b08
export PATH="$JAVA_HOME/bin:$PATH"
export MAVEN_HOME=/opt/apache-maven-3.8.6
export PATH="$MAVEN_HOME/bin:$PATH"

# Install Python dependencies
pip install --no-cache-dir -r requirements.txt

# Run CI with Maven using Python script
python ./ci/run_ci.py java --version 8