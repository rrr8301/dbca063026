#!/bin/bash

set -ex

# Source environment variables
if [ -f build/config/libipmctl.sh ]; then
    source build/config/libipmctl.sh
else
    echo "Environment configuration file not found!"
    exit 1
fi

# Check if Go is installed and the correct version
go version

# Run integration tests directly without Docker
make test-integration