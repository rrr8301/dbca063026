#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Add your commands here
# For example, if you have a Python script to run:
# python3 your_script.py

# Placeholder for actual commands
echo "Running the container..."

# Discover and run tests using unittest
if [ -d "tests" ]; then
    echo "Running tests..."
    python3 -m unittest discover -s tests -p "*.py"
else
    echo "No tests directory found. Please add your test suite."
fi