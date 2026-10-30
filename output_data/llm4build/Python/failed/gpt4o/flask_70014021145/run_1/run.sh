#!/bin/bash

# Activate Python virtual environment
source /opt/venv/bin/activate

# Install project dependencies
pip install -r flask/examples/celery/requirements.txt

# Run tests
UV_PYTHON_DOWNLOADS=never uv run --locked --no-default-groups --group dev tox -e py312 || true