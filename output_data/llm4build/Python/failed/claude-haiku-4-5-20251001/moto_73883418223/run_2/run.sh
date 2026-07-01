#!/bin/bash
set -e
cd /workspace
export TESTS_SKIP_REQUIRES_DOCKER=true
pytest tests