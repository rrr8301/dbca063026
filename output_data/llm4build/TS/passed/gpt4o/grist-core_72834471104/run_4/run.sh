#!/bin/bash

# Activate Python virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install project dependencies
pip install -r sandbox/requirements.txt
yarn install

# Run tests
set +e  # Continue on errors
yarn run lint:ci
yarn run test:smoke
yarn run test:python
yarn run test:client
yarn run test:common
yarn run test:stubs
yarn run test:gen-server
yarn run test:server
yarn run test:nbrowser --parallel --jobs 3
yarn run test:projects
yarn run test:eslint
set -e  # Stop on errors