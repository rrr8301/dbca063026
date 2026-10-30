#!/bin/bash

# Clone the repository (replace <repository-url> with the actual URL)
git clone https://github.com/your-username/your-repository.git /app
cd /app

# Set Java options
export JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8 -Duser.timezone=Asia/Shanghai"

# Build with Maven
mvn -V --no-transfer-progress -Dfastjson2.creator=reflect clean package \
    -Drat.skip=true -Dlicense.skip=true -Dmaven.compiler.source=11 -Dmaven.compiler.target=11 -X