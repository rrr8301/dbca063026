#!/bin/bash

# Install project dependencies
pip install -r requirements.txt

# Run tests
UV_PYTHON_DOWNLOADS=never uv run --locked tox -e py312