#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "Running application..."

# Assuming you have a main application script, uncomment and modify the following line
# python3.12 your_application.py

# Run your tests
if [ -d "tests" ]; then
    pytest tests/
else
    echo "Tests directory not found!"
    exit 1
fi

# Example error handling
if [ $? -ne 0 ]; then
    echo "An error occurred during execution."
    exit 1
fi