#!/usr/bin/env bash
set -e

cd /app

echo "=== Building with Maven ==="
./mvnw --no-transfer-progress -B install --file pom.xml

echo "=== Building Gradle plugin ==="
cd ./modules/swagger-gradle-plugin
./gradlew build --info
cd ../..

echo "=== Build completed successfully ==="
echo "FINAL_STATUS = SUCCESS"
