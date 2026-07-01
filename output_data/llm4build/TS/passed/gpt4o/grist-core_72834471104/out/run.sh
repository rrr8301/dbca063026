#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Activate Python virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install project dependencies
pip install -r sandbox/requirements.txt
yarn install

# Run tests
set +e  # Continue on errors
yarn run lint:ci || true
yarn run test:smoke || true
yarn run test:python || true
yarn run test:client || true
yarn run test:common || true
yarn run test:stubs || true
yarn run test:gen-server || true
yarn run test:server || true
yarn run test:nbrowser --parallel --jobs 3 || true
yarn run test:projects || true
yarn run test:eslint || true
set -e  # Stop on errors