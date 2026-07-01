#!/bin/bash
set -e

# Upgrade pip, setuptools, and install tox and virtualenv
python -m pip install --upgrade setuptools pip tox virtualenv

# Run tox with py environment
tox -e py