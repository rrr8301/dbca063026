#!/bin/bash

# Clone the repository (assuming the repo URL is known)
# git clone <repository-url> /app

# Navigate to the directory containing the pom.xml
cd httpcomponents-client/httpclient5

# Build with Maven
mvn -V --file pom.xml --no-transfer-progress -DtrimStackTrace=false -Djunit.jupiter.execution.parallel.enabled=false -Dhc.build.toolchain.version="17" -Pdocker -Drat.skip=true -Dlicense.skip=true