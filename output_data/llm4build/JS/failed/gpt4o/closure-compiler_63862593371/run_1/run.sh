#!/bin/bash

# Unset ANDROID_HOME if set
unset ANDROID_HOME

# Update Bazel dependencies
bazelisk sync

# Run Bazel tests
bazelisk test //:all