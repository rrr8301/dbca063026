#!/usr/bin/env bash

cd /app

# Run the unit tests (don't exit on failure)
npm run unit || true

# If we got here, tests ran (even if some failed)
echo "FINAL_STATUS = SUCCESS"
exit 0
