#!/bin/bash

# Run unit tests
pnpm nx run-many -t test:unit -p "${NEEDS_JOB_SETUP_OUTPUTS_AFFECTED_PROJECTS_STR}"

# Check for unexpected file changes
if [ -n "$(git status --porcelain)" ]; then
  echo "Tests generated unexpected file changes. Commit them before merging:"
  git status
  git diff
  exit 1
fi