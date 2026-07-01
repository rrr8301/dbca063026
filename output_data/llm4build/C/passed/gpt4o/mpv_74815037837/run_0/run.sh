#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone https://github.com/your/repo.git /app
cd /app

# Build with Meson
./ci/build-tumbleweed.sh -Db_ndebug=true

# Run Meson tests
meson test -C build