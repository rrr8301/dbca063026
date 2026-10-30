#!/bin/bash

set -e

# Print Java version for verification
echo "Java version:"
java -version

# Print Gradle version
echo "Gradle version:"
./gradlew --version

# Configure Gradle properties (simulating prepare-gradle-build action)
mkdir -p $HOME/.gradle
cat >> $HOME/.gradle/gradle.properties << EOF
systemProp.user.name=spring-builds+github
systemProp.org.gradle.internal.launcher.welcomeMessageEnabled=false
org.gradle.daemon=false
EOF

# Run the build (equivalent to ./gradlew build from the build action)
echo "Starting Gradle build..."
./gradlew build

# Read and display version from gradle.properties
echo "Reading version from gradle.properties..."
version=$(sed -n 's/version=\(.*\)/\1/p' gradle.properties)
echo "Version is $version"

echo "Build completed successfully!"