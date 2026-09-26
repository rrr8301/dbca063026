#!/usr/bin/env bash
set -e

echo "=== Conda Info ==="
python -m conda info --verbose

echo ""
echo "=== Conda Config ==="
python -m conda config --show-sources

echo ""
echo "=== Conda List ==="
python -m conda list --show-channel-urls

echo ""
echo "=== Running Tests ==="
# Create durations directory if it doesn't exist
mkdir -p durations

python -m pytest \
  --cov=conda \
  --durations-path=durations/Linux.json \
  --group=1 \
  --splits=3 \
  -m "integration" || true

echo ""
echo "FINAL_STATUS = SUCCESS"
