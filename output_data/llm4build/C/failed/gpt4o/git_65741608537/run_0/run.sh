#!/bin/bash

# Create builder user and set permissions
useradd builder --create-home
chown -R builder /workspace
chmod a+w $GITHUB_ENV

# Switch to builder user and run build and tests
sudo --preserve-env --set-home --user=builder bash -c "
    # Install project dependencies
    /workspace/ci/install-dependencies.sh

    # Run build and tests
    /workspace/ci/run-build-and-tests.sh

    # Print test failures if any
    if [ -n \"\$FAILED_TEST_ARTIFACTS\" ]; then
        /workspace/ci/print-test-failures.sh
    fi
"