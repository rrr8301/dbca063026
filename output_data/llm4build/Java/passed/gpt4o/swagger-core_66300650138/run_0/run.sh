#!/bin/bash

# Activate environment variables
export JAVA_HOME=/opt/jdk-17.0.8+7
export PATH="$JAVA_HOME/bin:$PATH"
export MAVEN_HOME=/opt/apache-maven-3.8.8
export PATH="$MAVEN_HOME/bin:$PATH"
export GRADLE_HOME=/opt/gradle-7.6
export PATH="$GRADLE_HOME/bin:$PATH"

# Build with Maven
./mvnw --no-transfer-progress -B install --file pom.xml

# Build with Gradle
cd ./modules/swagger-gradle-plugin
./gradlew build --info
cd ../..