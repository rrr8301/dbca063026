#!/bin/bash

# Activate Python environment
source /usr/bin/python3.12

# Run unit tests
tox -- --exitfirst -m unit

# Run integration tests
tox -- --exitfirst -m functional -k 'not harvesting'