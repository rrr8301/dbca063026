#!/bin/bash

# Install project dependencies
pnpm install --frozen-lockfile

# Run tests
bazel test --build_tests_only --test_tag_filters=-linker-integration-test --test_tag_filters=-e2e -- //... -//goldens/... -//integration/...