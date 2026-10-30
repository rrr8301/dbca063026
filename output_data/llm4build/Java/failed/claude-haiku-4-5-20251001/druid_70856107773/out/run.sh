#!/bin/bash
set -e

# Run Maven tests with all arguments passed to this script
# Arguments should include -Dtest pattern and other maven options
mvn clean test "$@"