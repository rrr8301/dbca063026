#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone https://github.com/mruby/mruby.git /app
cd /app

# Display Ruby version
ruby -v

# Display Clang version
clang --version

# Build and test
rake -m test:run:serial || true  # Ensure all tests run even if some fail