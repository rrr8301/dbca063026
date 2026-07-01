#!/usr/bin/env bash
set +e

echo "Starting Click test suite for Python 3.11..."
cd /app

# Run the exact test command from the GitHub Actions workflow
uv run --locked tox run -e py3.11

TEST_RESULT=$?

echo ""
echo "================================"
if [ $TEST_RESULT -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
fi
echo "================================"

exit $TEST_RESULT
