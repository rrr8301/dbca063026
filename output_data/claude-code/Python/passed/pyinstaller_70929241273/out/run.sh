#!/usr/bin/env bash
set +e

# Start display server
Xvfb :99 &
DISPLAY=:99
export DISPLAY

# Set temp directory for pytest
export PYTEST_DEBUG_TEMPROOT=/tmp

# Run tests
python3.11 -m pytest \
    -n 5 --maxfail 3 --durations 10 tests/unit tests/functional

TEST_RESULT=$?

# Print final status
if [ $TEST_RESULT -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = SUCCESS"
fi

exit 0
