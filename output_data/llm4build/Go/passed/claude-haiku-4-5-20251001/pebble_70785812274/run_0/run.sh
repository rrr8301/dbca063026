#!/bin/bash
set -e

# Activate Go environment
export PATH=/usr/local/go/bin:$PATH
export GOPATH=/home/testuser/go

# Run the test target
cd /workspace
GOTRACEBACK=all make testnocgo