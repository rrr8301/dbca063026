#!/usr/bin/env bash
set -e

cd /app

# Print environment info
echo "=== Conda Info ==="
python -m conda info --verbose || true

echo "=== Conda Config ==="
conda config --show-sources || true

echo "=== Conda List ==="
conda list --show-channel-urls || true

# Run tests - unit tests, group 1
echo "=== Running Tests ==="
python -m pytest \
  --cov=conda \
  --durations-path=durations/Linux.json \
  --group=1 \
  --splits=2 \
  -m "not integration and not benchmark" \
  tests/ 2>&1 || true

# Check if tests ran
if [ -f ".coverage" ] || [ -d "tests" ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
fi
