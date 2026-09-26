#!/bin/bash

# Activate Python environment
source /usr/bin/python3.10

# Install project dependencies
# Assuming dependencies are listed in requirements.txt or similar
# python3.10 -m pip install -r requirements.txt

# Run tests using the exact command from the YAML
python3.10 -m tox -epy310-marshmallow