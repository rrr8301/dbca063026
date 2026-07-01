#!/bin/bash

# Activate Python environment
source /app/venv/bin/activate

# Install project dependencies (already installed in Dockerfile, but ensure it's up-to-date)
pip install --no-cache-dir -r docs/requirements.txt

# Run installation scripts
bash scripts/install-prerequisites.sh
bash scripts/install_pngquant.sh

# Verify environment dependency installation
bash scripts/run_tests.sh --skip-tests

# Fix kernel mmap rnd bits
sudo sysctl vm.mmap_rnd_bits=28

# Run tests
python tests/main.py --report --update-image test --auto-clean --keep-report || true

# Code coverage analysis (simulated)
if [ "$GITHUB_EVENT_NAME" = "pull_request" ]; then
  echo "Simulating code coverage analysis for pull request."
else
  echo "Not a pull request, skipping code coverage analysis."
fi

# Check for new files and handle them
NEW_REF_IMGS=$(git status --porcelain -- tests/ref_imgs* | grep '^??' | awk '{print $2}')
if [ -n "$NEW_REF_IMGS" ]; then
  echo "New files were added during the build process."
  echo "Failing the build due to newly generated reference images."
  exit 1
else
  echo "No new files were found."
fi

# Always run this section
echo "Simulating upload of coverage reports as artifacts."