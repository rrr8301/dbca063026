#!/usr/bin/env bash

set -e

cd /app

# Activate venv
. .venv/bin/activate

# Print versions
python --version
python -c "import numpy; print('numpy %s' % numpy.__version__)"
python -c "import scipy; print('scipy %s' % scipy.__version__)"

# Install cvxpy in editable mode
uv pip install -e .

# Print installed solvers
python -c "import cvxpy; print(cvxpy.installed_solvers())"

# Run tests
pytest cvxpy/tests

echo "FINAL_STATUS = SUCCESS"
