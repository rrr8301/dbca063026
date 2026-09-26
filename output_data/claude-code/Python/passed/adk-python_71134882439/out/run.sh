#!/usr/bin/env bash

set -e

. .venv/bin/activate

pytest tests/unittests \
  --ignore=tests/unittests/artifacts/test_artifact_service.py \
  --ignore=tests/unittests/tools/google_api_tool/test_googleapi_to_openapi_converter.py

echo "FINAL_STATUS = SUCCESS"
