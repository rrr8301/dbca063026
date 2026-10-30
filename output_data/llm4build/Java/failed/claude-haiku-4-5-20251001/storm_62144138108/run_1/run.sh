#!/bin/bash

set -e

# Activate environment
export JDK_VERSION=17
export USER=github
export PATH=$JAVA_HOME/bin:$PATH

# Ensure clean state without storm artifacts
rm -rf ~/.m2/repository/org/apache/storm

# Set up project dependencies
/bin/bash ./dev-tools/gitact/gitact-install.sh "$(pwd)"

# Run build
/bin/bash ./dev-tools/gitact/gitact-script.sh "$(pwd)" Server