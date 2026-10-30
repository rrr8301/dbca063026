#!/bin/bash

# Create and activate Python virtual environment
python -m venv venv
source venv/bin/activate

# Run tests
pytest -n auto