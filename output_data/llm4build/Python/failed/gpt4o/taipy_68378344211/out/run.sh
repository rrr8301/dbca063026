#!/bin/bash

# Activate the pipenv environment and run commands within it
pipenv run pip install xmltodict

# Run tests with coverage
pipenv run pytest --cov=taipy --cov-report=xml:/app/coverage.xml --cov-config=.coveragerc