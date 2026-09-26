#!/bin/bash

# Activate virtual environment
python3.13 -m venv .venv
source .venv/bin/activate

# Install project dependencies
uv sync --extra test

# Run tests
pytest tests/unittests \
  --ignore=tests/unittests/artifacts/test_artifact_service.py \
  --ignore=tests/unittests/tools/google_api_tool/test_googleapi_to_openapi_converter.py || true

# Ensure all tests are executed, even if some fail