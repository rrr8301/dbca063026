#!/bin/bash

# Build with Maven
./mvnw --no-transfer-progress -B install --file pom.xml

# Build with Gradle
cd ./modules/swagger-gradle-plugin
./gradlew build --info
cd ../..