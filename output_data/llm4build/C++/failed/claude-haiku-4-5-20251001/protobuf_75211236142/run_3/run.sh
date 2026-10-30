#!/bin/bash

set -e

# Run Bazel tests with valid flags
# Using --build_tag_filters and --test_tag_filters to exclude tests marked with no_test tag
bazel test //... \
  --build_tag_filters=-no_test \
  --test_tag_filters=-no_test \
  --keep_going

exit 0