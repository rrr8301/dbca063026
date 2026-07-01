#!/usr/bin/env bash
set -e

cd /app

# Run the exact test command from the workflow
tox -e ci-py310 -- -v --color=yes

# Print final status
echo "FINAL_STATUS = SUCCESS"
