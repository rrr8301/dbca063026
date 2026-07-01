#!/bin/bash

# Activate environment variables
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Install project dependencies
mvn clean package -DskipTests -Djdk17 -Pjava17-target

# Run tests for each module
modules=("core" "python" "table" "connect" "tests" "misc")
for module in "${modules[@]}"; do
    echo "Running tests for module: $module"
    if [ "$module" == "python" ]; then
        # Setup Python environment
        python3.12 -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
    fi
    PROFILE="-Dinclude_hadoop_aws -Djdk17 -Pjava17-target -Dmodule=$module"
    ./tools/ci/test_controller.sh $module || true
done

# Ensure all test cases are executed
echo "All tests executed."