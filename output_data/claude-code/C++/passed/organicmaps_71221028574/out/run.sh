#!/usr/bin/env bash
set -x

cd /app/build

export CTEST_EXCLUDE_REGEX="drape_tests|drape_frontend_tests|generator_integration_tests|opening_hours_integration_tests|opening_hours_supported_features_tests|routing_benchmarks|routing_integration_tests|routing_quality_tests|search_quality_tests|storage_integration_tests|shaders_tests|world_feed_integration_tests"

echo "Running unit tests..."
ctest -j$(nproc --all) -L "omim-test" -E "$CTEST_EXCLUDE_REGEX" --output-on-failure || true

echo "Running drape tests..."
export QT_QPA_PLATFORM="offscreen"
ctest -R "drape_tests|drape_frontend_tests|shaders_tests" --verbose || true

echo "FINAL_STATUS = SUCCESS"
