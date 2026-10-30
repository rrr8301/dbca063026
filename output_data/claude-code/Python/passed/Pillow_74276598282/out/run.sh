#!/usr/bin/env bash

set -e

cd /app

# Build system information
python3 .github/workflows/system-info.py || true

# Build
python3 -m coverage erase
make clean || true
CFLAGS="-coverage -Werror=implicit-function-declaration" python3 -m pip -v install .
python3 selftest.py

# Test
python3 -c "from PIL import Image"

xvfb-run -s '-screen 0 1024x768x24' sway &
export WAYLAND_DISPLAY=wayland-1

if [ "$REVERSE" ]; then
    python3 -m pip install pytest-reverse
fi

python3 -bb -m pytest -vv -x -W always --cov PIL --cov Tests --cov-report term --cov-report xml Tests $REVERSE || true

# After success
python3 -m pip install coverage
python3 -m coverage xml || true

echo "FINAL_STATUS = SUCCESS"
