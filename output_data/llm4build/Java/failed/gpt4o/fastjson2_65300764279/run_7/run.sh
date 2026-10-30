#!/bin/bash

# Clone the repository (replace <repository-url> with the actual URL)
git clone https://github.com/your-username/your-repository.git /app
cd /app

# Set Java options
export JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8 -Duser.timezone=Asia/Shanghai"

# Ensure Maven uses Java 11
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Build with Maven
mvn -V --no-transfer-progress -Dfastjson2.creator=reflect clean package \
    -Drat.skip=true -Dlicense.skip=true -Dmaven.compiler.source=11 -Dmaven.compiler.target=11 -X