#!/bin/bash

# Activate Python environment
python3 -m venv venv
source venv/bin/activate

# Install project dependencies
pip install -r flask/examples/celery/requirements.txt

# Run tests with the specified environment
uv run --locked tox -e py313