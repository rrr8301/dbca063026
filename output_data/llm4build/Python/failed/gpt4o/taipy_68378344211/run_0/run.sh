#!/bin/bash

# Activate the pipenv environment
pipenv shell

# Install additional Python packages
pip install xmltodict

# Run tests with coverage
pipenv run pytest --cov=taipy --cov-report=xml:/app/coverage.xml --cov-config=.coveragerc