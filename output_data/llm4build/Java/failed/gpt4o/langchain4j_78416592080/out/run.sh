#!/bin/bash

# Activate environment variables
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Print Maven version
mvn --version

# Compile and unit test with JDK 21
set -o pipefail
mvn -B -U -DembeddingsSkipCache -T8C test javadoc:aggregate -Drat.skip=true -Dlicense.skip=true 2>&1 | tee maven-output.log

# Surface build errors if any
if [ $? -ne 0 ]; then
  echo '## Build Errors (JDK 21)'
  echo ''
  echo 'Check maven-output.log for details.'
fi