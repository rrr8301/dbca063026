#!/bin/bash

# Activate Python environment
source /usr/bin/python3.12

# Install project dependencies
pip install -r requirements.txt

# Run tests
UV_PYTHON_DOWNLOADS=never uv run --locked tox run -e py3.12