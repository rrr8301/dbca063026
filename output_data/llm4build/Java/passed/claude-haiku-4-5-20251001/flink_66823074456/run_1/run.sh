#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Verify Java and Maven are available
echo "Java version:"
java -version
echo ""
echo "Maven version:"
mvn -version
echo ""

# Run the test command from the YAML
echo "Running Maven test for flink-core module..."
mvn clean test -pl flink-core -Dinclude_hadoop_aws -Djdk17 -Pjava17-target

# Post-build disk info
echo ""
echo "Post-build Disk Info:"
df -h

echo ""
echo "Top 15 biggest directories in terms of used disk space:"
du -sh /* | sort -rh | head -15

echo ""
echo "Test execution completed successfully!"