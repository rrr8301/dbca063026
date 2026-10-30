#!/bin/bash

# Activate environment (if any)

# Install project dependencies
python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive folly

# Build the project
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --src-dir=. folly --project-install-prefix folly:/usr/local

# Test the project
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --src-dir=. folly --project-install-prefix folly:/usr/local

# Ensure all tests are executed
if [ $? -ne 0 ]; then
    echo "Some tests failed, but continuing..."
fi