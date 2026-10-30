#!/bin/bash

set -e

# Change to workspace directory
cd /workspace

# Display Python version for verification
echo "Python version:"
python3 --version

# Display tox version
echo "Tox version:"
python3 -m tox --version

# Run tox with the py314-marshmallow environment
echo "Running tox -e py314-marshmallow..."
python3 -m tox -e py314-marshmallow

echo "Test execution completed successfully!"