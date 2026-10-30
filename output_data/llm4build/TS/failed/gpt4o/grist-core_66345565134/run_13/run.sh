#!/bin/bash

# Activate Python virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install project dependencies
pip install -r grist-core/sandbox/requirements.txt

# Run main tests without minio and redis
mkdir -p $MOCHA_WEBDRIVER_LOGDIR
export GREP_TESTS=$(echo $TESTS | sed "s/.*:nbrowser-\([^:]*\).*/\1/")
MOCHA_WEBDRIVER_SKIP_CLEANUP=1 MOCHA_WEBDRIVER_HEADLESS=1 yarn run test:nbrowser --parallel --jobs 3

# Prepare for saving artifact (simulated)
ARTIFACT_NAME=logs-$(echo $TESTS | sed 's/[^-a-zA-Z0-9]/_/g')
echo "Artifact name is '$ARTIFACT_NAME'"
mkdir -p $TESTDIR
find $TESTDIR -iname "*.socket" -exec rm {} \;