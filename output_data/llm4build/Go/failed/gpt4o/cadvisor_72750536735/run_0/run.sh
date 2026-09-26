#!/bin/bash

set -ex

# Source environment variables
source build/config/libipmctl.sh

# Run integration tests
make docker-test-integration