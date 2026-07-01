#!/bin/bash

# Prepare Mimir for Maven 4.x
mkdir -p ~/.mimir
cp .github/ci-mimir-session.properties ~/.mimir/session.properties
cp .github/ci-mimir-daemon.properties ~/.mimir/daemon.properties
mkdir -p ~/.m2
cp .github/ci-extensions.xml ~/.m2/extensions.xml

# Assume Maven distribution is available locally
mkdir -p maven-local
tar xzf maven-dist/apache-maven-*-bin.tar.gz -C maven-local --strip-components 1
export MAVEN_HOME=$PWD/maven-local
export PATH=$MAVEN_HOME/bin:$PATH

# Build Maven and ITs and run them
mvn install -e -B -V -Prun-its,mimir -Drat.skip=true -Dlicense.skip=true