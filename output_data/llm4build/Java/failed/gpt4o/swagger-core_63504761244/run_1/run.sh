#!/bin/bash

# Build with Maven
mvn --no-transfer-progress -B install -Drat.skip=true -Dlicense.skip=true --file pom.xml

# Build with Gradle
cd ./modules/swagger-gradle-plugin
./gradlew build --info
cd ../..