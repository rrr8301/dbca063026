#!/bin/bash

# Ensure uv is installed and available
if ! command -v uv &> /dev/null; then
    echo "uv could not be found, attempting to install..."
    curl -sSL https://install.astral.sh | bash
    export PATH="/root/.local/bin:${PATH}"
fi

# Sync dependencies
uv sync --group=test

# Run tests
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

# If tests succeed, build directory markdown
if [ $? -eq 0 ]; then
  python scripts/build_directory_md.py 2>&1 | tee DIRECTORY.md
fi