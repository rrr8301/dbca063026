#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Set Maven arguments from workflow
export MAVEN_ARGS="-B -V -ntp -e -Djansi.passthrough=true -Dstyle.color=always"

# Run Maven verify (includes compile, test, package, verify phases)
mvn $MAVEN_ARGS verify -Drat.skip=true -Dlicense.skip=true

echo "Build and tests completed successfully"