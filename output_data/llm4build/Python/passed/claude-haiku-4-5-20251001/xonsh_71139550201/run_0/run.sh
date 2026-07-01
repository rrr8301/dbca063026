#!/bin/bash
set -e

# Add uv to PATH
export PATH="$HOME/.local/bin:$PATH"

# Clone the repository
if [ ! -d "/workspace/repo" ]; then
    git clone https://github.com/xonsh/xonsh.git /workspace/repo
fi

cd /workspace/repo

# Set environment variables
export UV_SYSTEM_PYTHON=1
export DEFAULT_PYTHON_VERSION=3.12

# Install dependencies
uv pip install --system -e ".[test]"

# Run tests
python -m xonsh run-tests.xsh test -- --timeout=600