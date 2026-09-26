#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Activate Python environment
python3.10 -m venv venv
source venv/bin/activate

# Install Python dependencies if any (placeholder)
# Uncomment and modify the following line if you have a requirements.txt
# pip install -r requirements.txt

# Ensure the run_bazel.py script is executable
chmod +x ./scripts/run_bazel.py

# Run tests using the exact command from the YAML
# Removed the unrecognized Bazel option
./scripts/run_bazel.py --attempts=5 --jobs-on-last-attempt=4 test -c opt --target_pattern_file=${TARGETS_FILE}

# Ensure all tests are executed
set +e
./scripts/run_bazel.py --attempts=5 --jobs-on-last-attempt=4 test -c opt --target_pattern_file=${TARGETS_FILE}
set -e