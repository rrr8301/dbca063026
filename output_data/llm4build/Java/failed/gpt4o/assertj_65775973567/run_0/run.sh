#!/bin/bash

# Activate environment (if needed)

# Install project dependencies
# Assuming Maven dependencies are already handled by the Maven wrapper

# Run tests
mvn -B -V -ntp -e -Djansi.passthrough=true -Dstyle.color=always -Drat.skip=true -Dlicense.skip=true verify