#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Placeholder for actual commands
echo "Running the container..."

# Check if the tests directory exists and is not empty
if [ -d "/app/tests" ] && [ "$(ls -A /app/tests)" ]; then
    echo "Running tests..."
    python3 -m unittest discover -s /app/tests -p "*.py"
else
    echo "No tests found. Please add your test suite."
fi