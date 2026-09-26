#!/usr/bin/env bash
set -e

npm test
RESULT=$?

if [ $RESULT -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = FAIL"
fi

exit $RESULT
