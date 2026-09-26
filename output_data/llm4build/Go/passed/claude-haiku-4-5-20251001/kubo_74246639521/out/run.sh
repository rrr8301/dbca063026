#!/bin/bash
set -e

make test_unit && [[ ! $(jq -s -c 'map(select(.Action == "fail")) | .[]' test/unit/gotest.json) ]]