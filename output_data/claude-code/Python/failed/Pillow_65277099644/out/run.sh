#!/usr/bin/env bash

set -e

export PYTHONOPTIMIZE=1
export REVERSE="--reverse"

cd /app

python3.12 -m coverage erase
make clean
CFLAGS="-coverage -Werror=implicit-function-declaration" python3.12 -m pip install -v .
python3.12 selftest.py

python3.12 -c "from PIL import Image"

# Run tests with xvfb and wayland
xvfb-run -s '-screen 0 1024x768x24' sway &
export WAYLAND_DISPLAY=wayland-1
sleep 2

python3.12 -bb -m pytest -vv -x -W always --cov PIL --cov Tests --cov-report term --cov-report xml Tests $REVERSE || true

# Run after_success script
python3.12 -m pip install coverage
python3.12 -m coverage xml

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS=$FINAL_STATUS"
