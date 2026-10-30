#!/bin/bash

# Clone the repository
git clone https://github.com/your-repo/your-project.git /app
cd /app

# Install GS1 Syntax Engine
git clone --depth=1 https://github.com/gs1/gs1-syntax-engine && \
cd gs1-syntax-engine/src/c-lib && \
make lib && sudo make install && \
cd /app

# Set locale
sudo locale-gen de_DE.UTF-8 && sudo update-locale

# Create build environment
git config --global --add safe.directory /app && \
cmake -E make_directory build

# Configure CMake
cd build
CMAKE_PREFIX_PATH=/usr/lib/x86_64-linux-gnu/cmake/Qt5 cmake /app -DCMAKE_BUILD_TYPE=Release -DZINT_TEST=ON -DZINT_STATIC=ON

# Build the project
cmake --build . -j8 --config Release

# Run tests
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$(pwd)/backend" PATH=$PATH:"$(pwd)/frontend" QT_QPA_PLATFORM=offscreen ctest -V -C Release || true