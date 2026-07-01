#!/bin/bash

# Activate Python environment
python3.13 -m venv venv
source venv/bin/activate

# Install project dependencies
pip install -r flask/examples/celery/requirements.txt

# Run tests
uv run --locked tox run