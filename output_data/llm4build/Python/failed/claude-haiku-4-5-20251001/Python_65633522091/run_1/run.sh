#!/bin/bash
set -e

# Ensure uv is in PATH
export PATH="$HOME/.local/bin:$PATH"

# Prevent uv from downloading Python versions
export UV_PYTHON_DOWNLOADS=never

# Install project dependencies via uv
echo "Installing project dependencies..."
uv sync --group=test

# Run pytest with the exact configuration from the workflow
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
  --cov=. .

# Build directory markdown (conditional on test success)
echo "Building directory markdown..."
python3 scripts/build_directory_md.py 2>&1 | tee DIRECTORY.md

echo "Build completed successfully!"