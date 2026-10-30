#!/bin/bash

# Activate Python virtual environment
source /opt/venv/bin/activate

# Run tests
set +e  # Continue on errors
mage -v test