#!/bin/bash
set -e

# Activate Python 3.10 environment
export PATH="/usr/bin:$PATH"

# Run tests with tox
tox -e tests