#!/bin/bash

# Activate Python environment
# Note: The source command is not needed for activating Python in this context
# as we are not using a virtual environment here.

# Decode and set MOSEK license
echo $MOSEK_CI_BASE64 | base64 -d > mosek.lic
export MOSEKLM_LICENSE_FILE=$(realpath mosek.lic)

# Install project dependencies
source continuous_integration/install_dependencies.sh

# Run tests
source continuous_integration/test_script.sh