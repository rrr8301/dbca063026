#!/usr/bin/env bash
set -e

# Configure Gradle properties like the CI action does
mkdir -p $HOME/.gradle
echo 'systemProp.user.name=spring-builds+github' >> $HOME/.gradle/gradle.properties
echo 'systemProp.org.gradle.internal.launcher.welcomeMessageEnabled=false' >> $HOME/.gradle/gradle.properties
echo 'org.gradle.daemon=false' >> $HOME/.gradle/gradle.properties

# Run the build
cd /app
./gradlew build

echo "FINAL_STATUS = SUCCESS"
