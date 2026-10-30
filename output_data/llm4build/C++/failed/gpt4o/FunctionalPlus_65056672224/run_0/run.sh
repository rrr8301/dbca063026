#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone https://github.com/your/repo.git /app
cd /app

# Run setup script
source script/ci_setup_linux.sh

# Install libc++ and set CXXFLAGS
apt-get update && apt-get install -y --no-install-recommends libunwind-22-dev
echo "CXXFLAGS=-stdlib=libc++" >> /etc/environment
source /etc/environment

# Run build and test script
script/ci.sh run_tests