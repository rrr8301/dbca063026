#!/bin/bash

# Activate Python environment
source /usr/bin/activate

# Install project dependencies
pip install -r pip/tests/data/completion_paths/requirements.txt

# Run unit tests
nox -s test-3.13 -- tests/unit --verbose --numprocesses auto --showlocals

# Run integration tests
nox -s test-3.13 --no-install -- tests/functional --verbose --numprocesses auto --showlocals --durations=15