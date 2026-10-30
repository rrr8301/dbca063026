#!/bin/bash

# Install project dependencies
# Assuming dependencies are listed in requirements.txt or similar
# Uncomment the following line if you have a requirements.txt
# python3.10 -m pip install -r requirements.txt

# Run tests using the exact command from the YAML
python3.10 -m tox -e py310-marshmallow