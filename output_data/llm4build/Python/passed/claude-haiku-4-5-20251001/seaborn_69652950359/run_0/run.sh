#!/bin/bash
set -e

# Clone the repository (simulating actions/checkout)
if [ ! -d "/workspace/seaborn" ]; then
    git clone https://github.com/mwaskom/seaborn.git /workspace/seaborn
fi

cd /workspace/seaborn

# Upgrade pip and wheel
pip install --upgrade pip wheel

# Install seaborn with dev and stats extras
# install=full, deps=latest (no pinned deps)
pip install ".[dev,stats]"

# Run tests
make test