#!/usr/bin/env bash
set -e

export PATH="/root/.cargo/bin:$PATH"

cd /app
. .venv/bin/activate

python --version
python -c "import numpy; print('numpy %s' % numpy.__version__)"
python -c "import scipy; print('scipy %s' % scipy.__version__)"

uv pip list
uv pip install -e .

python -c "import cvxpy; print(cvxpy.installed_solvers())"

pytest cvxpy/tests

echo "FINAL_STATUS = SUCCESS"
