#!/usr/bin/env bash

set -e

cd /app

# Run pytest with the same markers as in the CI job
pipenv run pytest -m "not orchestrator_dispatcher and not standalone and not teste2e" tests

echo "FINAL_STATUS = SUCCESS"
