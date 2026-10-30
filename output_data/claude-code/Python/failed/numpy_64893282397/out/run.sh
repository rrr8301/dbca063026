#!/usr/bin/env bash

set -e

MESON_ARGS="-Dallow-noblas=true -Dcpu-baseline=none -Dcpu-dispatch=none"
export PKG_CONFIG_PATH=./.openblas

cd /app

echo "::group::Installing Build Dependencies"
python3.12 -m pip install -r requirements/build_requirements.txt --break-system-packages
echo "::endgroup::"

echo "::group::Building NumPy"
spin build --clean -- ${MESON_ARGS}
echo "::endgroup::"

echo "::group::Meson Log"
cat build/meson-logs/meson-log.txt 2>/dev/null || echo "Meson log not found"
echo "::endgroup::"

echo "::group::Installing Test Dependencies"
python3.12 -m pip install -r requirements/test_requirements.txt --break-system-packages
echo "::endgroup::"

echo "::group::Test NumPy"
spin test -- --durations=10 --timeout=600
echo "::endgroup::"

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
