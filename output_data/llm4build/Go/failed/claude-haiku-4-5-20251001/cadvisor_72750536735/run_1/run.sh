#!/bin/bash

set -ex

# Source the configuration file
source build/config/libipmctl.sh

# Run integration tests
make docker-test-integration

exit 0