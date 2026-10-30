#!/bin/bash

# Activate Python environment
source /usr/bin/python3.12

# Install project dependencies
pip install -r flask/examples/celery/requirements.txt

# Run tests
UV_PYTHON_DOWNLOADS=never uv run --locked --no-default-groups --group dev tox run -e py312 || true