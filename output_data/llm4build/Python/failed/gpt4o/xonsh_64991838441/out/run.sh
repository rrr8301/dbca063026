#!/bin/bash

# Activate the virtual environment
source venv/bin/activate

# Run tests
set +e  # Continue executing even if some tests fail
python -m xonsh run-tests.xsh test -- --timeout=240