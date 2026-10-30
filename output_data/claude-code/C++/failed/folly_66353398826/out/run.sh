#!/usr/bin/env bash
set -e

cd /app

# Run the exact test command from the workflow
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --src-dir=. folly --project-install-prefix folly:/usr/local

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
