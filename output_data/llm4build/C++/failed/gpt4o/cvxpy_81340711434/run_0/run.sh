#!/bin/bash

# Activate Python environment
source /usr/bin/python3.11

# Simulate setting environment variables
echo "PYTHON_SUBVERSION=11" >> $GITHUB_ENV
echo "MOSEKLM_LICENSE_FILE=$(realpath mosek.lic)" >> $GITHUB_ENV

# Install dependencies
source continuous_integration/install_dependencies.sh

# Run tests
source continuous_integration/test_script.sh