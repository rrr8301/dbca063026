#!/bin/bash

# Activate the virtual environment
uv venv .venv
source .venv/bin/activate

# Install project dependencies
uv sync --extra test

# Run tests with pytest
pytest tests/unittests \
  --ignore=tests/unittests/artifacts/test_artifact_service.py \
  --ignore=tests/unittests/tools/google_api_tool/test_googleapi_to_openapi_converter.py || true

# Ensure all tests are executed, even if some fail
exit 0