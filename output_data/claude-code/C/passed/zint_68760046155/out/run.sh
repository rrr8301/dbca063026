#!/usr/bin/env bash

set -e

cd /app/build

export BUILD_TYPE=Release
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$(pwd)/backend"
export PATH=$PATH:"$(pwd)/frontend"
export QT_QPA_PLATFORM=offscreen

ctest -V -C $BUILD_TYPE

echo "FINAL_STATUS = SUCCESS"
