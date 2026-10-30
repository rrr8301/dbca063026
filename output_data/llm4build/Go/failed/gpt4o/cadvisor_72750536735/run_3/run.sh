#!/bin/bash

set -ex

# Source environment variables
if [ -f build/config/libipmctl.sh ]; then
    source build/config/libipmctl.sh
else
    echo "Environment configuration file not found!"
    exit 1
fi

# Run integration tests directly without Docker
make test-integration