#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone https://github.com/your/repo.git /app
cd /app

# Decode and write the set_env.py script
echo $SET_ENV_SCRIPT | base64 --decode > set_env.py

# Run tests using tox with the correct environment
python -m tox -e py312 -v --develop -- -n=4 --run-slow

# Indicate job completion
echo "Job completed"