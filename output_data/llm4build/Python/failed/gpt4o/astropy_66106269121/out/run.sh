#!/bin/bash

# Ensure the /app directory is clean before cloning
rm -rf /app/*

# Check if GITHUB_PAT is set
if [ -z "$GITHUB_PAT" ]; then
    echo "Error: GITHUB_PAT environment variable is not set."
    exit 1
fi

# Clone the repository using a personal access token
git clone https://$GITHUB_PAT@github.com/your/repo.git /app
cd /app

# Decode and write the set_env.py script if provided
if [ -n "$SET_ENV_SCRIPT" ]; then
    echo $SET_ENV_SCRIPT | base64 --decode > set_env.py
fi

# Ensure a valid tox configuration file exists
if [ ! -f "tox.ini" ] && [ ! -f "setup.cfg" ] && [ ! -f "pyproject.toml" ] && [ ! -f "tox.toml" ]; then
    echo "[tox]" > tox.ini
    echo "envlist = py312" >> tox.ini
fi

# Run tests using tox with the correct environment
python -m tox -e py312 -v --develop -- -n=4 --run-slow

# Indicate job completion
echo "Job completed"