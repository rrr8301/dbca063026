#!/bin/bash

# Activate Python environment and install dependencies
pipenv install --dev --python=3.11

# Run tests
pipenv run pytest -m "not orchestrator_dispatcher and not standalone and not teste2e" tests