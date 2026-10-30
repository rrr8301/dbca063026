#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Run pytest with TESTS_SKIP_REQUIRES_DOCKER environment variable
export TESTS_SKIP_REQUIRES_DOCKER=true
pytest tests