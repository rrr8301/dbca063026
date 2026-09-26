#!/bin/bash

# Unset ANDROID_HOME if set
unset ANDROID_HOME

# Run Bazel tests with the flag to ignore direct dependency checks
bazelisk test //:all --check_direct_dependencies=off