#!/usr/bin/env bash

set -eu -o errtrace

cd /app

echo "========== Starting Build and Test =========="
echo "Python version:"
python3 --version
echo "Python location:"
which python3

export cache_dir="/cache"
mkdir -p "${cache_dir}"

echo ""
echo "========== Building project =========="
bash build_tools/ci/build_posix.sh || {
    echo "Build failed"
    echo "FINAL_STATUS = FAIL"
    exit 1
}

echo ""
echo "========== Running Integration Tests =========="
bash build_tools/ci/test_posix.sh nightly || {
    echo "Integration tests failed"
    echo "FINAL_STATUS = FAIL"
    exit 1
}

echo ""
echo "========== Checking Generated Sources =========="
bash build_tools/ci/check_generated_sources.sh || {
    echo "Generated sources check failed"
    echo "FINAL_STATUS = FAIL"
    exit 1
}

echo ""
echo "========== All tests completed successfully =========="
echo "FINAL_STATUS = SUCCESS"
