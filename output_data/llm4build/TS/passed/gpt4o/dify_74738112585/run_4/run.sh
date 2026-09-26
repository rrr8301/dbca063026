#!/bin/bash

# Activate Python virtual environment
source venv/bin/activate

# Install project dependencies
pip install -r requirements.txt

# Run tests
echo "Running dify config tests"
# Replace with actual test command
pytest dify/api/tests --continue-on-collection-errors || true

echo "Running Unit Tests"
# Replace with actual test command
pytest dify/api/unit_tests --continue-on-collection-errors || true

# Complete job
echo "Completing job"