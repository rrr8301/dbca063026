#!/bin/bash

# Activate environments
export PATH="/usr/bin:$PATH"

# Ensure a clean state without storm artifacts
rm -rf ~/.m2/repository/org/apache/storm

# Set up project dependencies
/bin/bash ./dev-tools/gitact/gitact-install.sh `pwd`

# Run build
export JDK_VERSION=17
export USER=github
/bin/bash ./dev-tools/gitact/gitact-script.sh `pwd` Core