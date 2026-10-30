#!/bin/bash

set -e

# Ensure uv is in PATH
export PATH="/root/.cargo/bin:$PATH"

# Verify Python version
echo "Python version:"
python3 --version

# Verify uv installation
echo "uv version:"
uv --version

# Sync dependencies with test group
echo "Syncing dependencies..."
uv sync --group=test

# Run pytest with coverage and parallel execution
echo "Running tests..."
uv run --with=pytest-run-parallel pytest \
  --iterations=8 --parallel-threads=auto \
  --ignore=computer_vision/cnn_classification.py \
  --ignore=docs/conf.py \
  --ignore=dynamic_programming/k_means_clustering_tensorflow.py \
  --ignore=machine_learning/local_weighted_learning/local_weighted_learning.py \
  --ignore=machine_learning/lstm/lstm_prediction.py \
  --ignore=neural_network/input_data.py \
  --ignore=project_euler/ \
  --ignore=quantum/q_fourier_transform.py \
  --ignore=scripts/validate_solutions.py \
  --ignore=web_programming/current_stock_price.py \
  --ignore=web_programming/fetch_anime_and_play.py \
  --cov-report=term-missing:skip-covered \
  --cov=. . || TEST_FAILED=1

# Generate DIRECTORY.md if tests passed
if [ -z "$TEST_FAILED" ]; then
  echo "Tests passed. Generating DIRECTORY.md..."
  python3 scripts/build_directory_md.py 2>&1 | tee DIRECTORY.md
else
  echo "Tests failed. Skipping DIRECTORY.md generation."
  exit 1
fi