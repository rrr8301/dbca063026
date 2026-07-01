#!/bin/bash

set -e

# Print Python version
python --version

# Initialize ccache
ccache -s

# Get git description
git describe

# Install Matplotlib with coverage flags
export CPPFLAGS='--coverage -fprofile-abs-path'

python -m pip install --break-system-packages --no-deps --no-build-isolation --verbose \
  --config-settings=setup-args="-DrcParams-backend=Agg" \
  --editable .[dev]

unset CPPFLAGS

# Run pytest
pytest -rfEsXR -n auto \
  --maxfail=50 --timeout=300 --durations=25 \
  --cov-report=xml --cov=lib --log-level=DEBUG --color=yes

# Cleanup non-failed image files if tests failed
if [ -d ./result_images ]; then
  find ./result_images -name "*-expected*.png" | while read file; do
    if [[ $file == *-expected_???.png ]]; then
      extension=${file: -7:3}
      base=${file%*-expected_$extension.png}_$extension
    else
      extension="png"
      base=${file%-expected.png}
    fi
    if [[ ! -e ${base}-failed-diff.png ]]; then
      indent=""
      list=($file $base.png)
      if [[ $extension != "png" ]]; then
        list+=(${base%_$extension}-expected.$extension ${base%_$extension}.$extension)
      fi
      for to_remove in "${list[@]}"; do
        if [[ -e $to_remove ]]; then
          rm $to_remove
          echo "${indent}Removed $to_remove"
        fi
        indent+=" "
      done
    fi
  done

  if [ "$(find ./result_images -mindepth 1 -type d)" ]; then
    find ./result_images/* -type d -empty -delete
  fi
fi

# Filter C coverage
LCOV_IGNORE_ERRORS='mismatch,unused'
lcov --rc lcov_branch_coverage=1 --ignore-errors $LCOV_IGNORE_ERRORS \
  --capture --directory . --output-file coverage.info
lcov --rc lcov_branch_coverage=1 --ignore-errors $LCOV_IGNORE_ERRORS \
  --output-file coverage.info --extract coverage.info $PWD/src/'*' $PWD/lib/'*'
lcov --rc lcov_branch_coverage=1 --ignore-errors $LCOV_IGNORE_ERRORS \
  --list coverage.info
find . -name '*.gc*' -delete

echo "Tests completed successfully!"