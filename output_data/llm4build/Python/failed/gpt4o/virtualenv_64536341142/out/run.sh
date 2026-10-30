#!/bin/bash

# Load pyenv automatically
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Activate Python 3.14 environment and install tox
pyenv shell 3.14.0
python3.14 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install tox>=4.32 tox-uv

# Set TOXENV environment variable
export TOXENV=3.10

# Setup test suite
tox run -vvvv --notest --skip-missing-interpreters false

# Run test suite
tox run --skip-pkg-install || true  # Ensure all tests run even if some fail