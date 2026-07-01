#!/bin/bash

# Install project dependencies
pip install -r requirements.txt

# Run tests with Maven and Python
mvn test -Drat.skip=true -Dlicense.skip=true
python3.8 ./ci/run_ci.py java --version 17