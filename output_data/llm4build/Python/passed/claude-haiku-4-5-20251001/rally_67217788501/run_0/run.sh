#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Run tests using the exact command from the workflow
make test-3.11