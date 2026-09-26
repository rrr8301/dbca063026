#!/bin/bash

# Clone the repository
git clone https://github.com/apache/lucene.git /app
cd /app

# Run gradle tests
./gradlew displayGradleDiagnostics allOptions test "-Ptask.times=true" "-Pvalidation.errorprone=false" \
  -DTEST_JVM_ARGS="-XX:TieredStopAtLevel=1 -XX:+UseParallelGC -XX:ActiveProcessorCount=1"

# List automatically-initialized gradle.properties
cat gradle.properties