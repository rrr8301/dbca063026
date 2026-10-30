#!/bin/bash

# Activate the virtual environment
source /workspace/venv/bin/activate

# Start MariaDB service
sudo service mysql start

# Run the test suite
cd Tests
PYTHONMALLOC=debug LD_PRELOAD="$(realpath "$(gcc -print-file-name=libasan.so)") $(realpath "$(gcc -print-file-name=libstdc++.so)")" ASAN_OPTIONS="detect_leaks=0" coverage run --source Bio,BioSQL run_tests.py --offline
coverage xml