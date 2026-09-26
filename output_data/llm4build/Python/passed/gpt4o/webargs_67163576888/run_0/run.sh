#!/bin/bash

# Activate the Python environment (if any virtual environment is used)
# source /path/to/venv/bin/activate

# Install project dependencies
# Assuming dependencies are managed by tox, no additional installation needed

# Run tests using tox
tox -epy314-marshmallow || true  # Ensure all tests run even if some fail