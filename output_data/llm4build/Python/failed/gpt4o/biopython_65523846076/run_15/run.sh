#!/bin/bash

# Activate the virtual environment
source /workspace/venv/bin/activate

# Start MySQL service
sudo service mysql start

# Check if MySQL started successfully
if ! sudo service mysql status; then
    echo "MySQL failed to start"
    exit 1
fi

# Run the test suite
cd Tests
PYTHONMALLOC=debug LD_PRELOAD="$(realpath "$(gcc -print-file-name=libasan.so)") $(realpath "$(gcc -print-file-name=libstdc++.so)")" ASAN_OPTIONS="detect_leaks=0" coverage run --source Bio,BioSQL run_tests.py --offline
coverage xml

# Capture the exit code of the test suite
TEST_EXIT_CODE=$?

# Print a message based on the test results
if [ $TEST_EXIT_CODE -ne 0 ]; then
    echo "Tests failed with exit code $TEST_EXIT_CODE"
else
    echo "Tests passed successfully"
fi

# Exit with the test suite's exit code
exit $TEST_EXIT_CODE