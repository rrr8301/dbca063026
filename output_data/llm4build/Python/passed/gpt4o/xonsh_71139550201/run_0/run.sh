#!/bin/bash

# Activate the virtual environment
source /venv/bin/activate

# Install project dependencies
UV_PYTHON_DOWNLOADS=never uv pip install --system -e ".[test]"

# Run tests
python -m xonsh run-tests.xsh test -- --timeout=600