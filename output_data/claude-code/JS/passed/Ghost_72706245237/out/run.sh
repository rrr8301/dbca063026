#!/usr/bin/env bash

# Set timezone
export TZ=America/New_York

# Set required environment variables for tests
export FORCE_COLOR=0
export GHOST_UNIT_TEST_VARIANT=ci
export NX_SKIP_LOG_GROUPING=true
export logging__level=fatal

echo "Starting unit tests..."
echo ""

cd /app

# Get all projects with a test:unit target
echo "Determining projects..."
ALL_PROJECTS=$(pnpm nx show projects --json 2>/dev/null)

if [ -z "$ALL_PROJECTS" ] || [ "$ALL_PROJECTS" = "[]" ]; then
    echo "No projects detected, running all test:unit targets..."
    pnpm nx run-many -t test:unit 2>&1
    TEST_EXIT=$?
else
    # Convert JSON array to comma-separated list
    PROJECTS_STR=$(echo "$ALL_PROJECTS" | jq -r '.[]' | paste -sd ',' -)

    echo "Projects detected: $(echo "$PROJECTS_STR" | tr ',' '\n' | wc -l) projects"
    echo ""

    # Run unit tests with detected projects
    echo "Running: pnpm nx run-many -t test:unit -p '$PROJECTS_STR'"
    pnpm nx run-many -t test:unit -p "$PROJECTS_STR" 2>&1
    TEST_EXIT=$?
fi

echo ""
echo "Test execution completed with exit code: $TEST_EXIT"

# Check for unexpected file changes
echo ""
echo "Checking for unexpected file changes..."
if [ -n "$(git status --porcelain)" ]; then
    echo "ERROR: Tests generated unexpected file changes!"
    echo "Changed files:"
    git status --porcelain
    echo ""
    echo "Diff:"
    git diff | head -100
    FINAL_STATUS="FAIL"
    EXIT_CODE=1
else
    echo "No unexpected file changes detected."
    if [ $TEST_EXIT -eq 0 ]; then
        FINAL_STATUS="SUCCESS"
        EXIT_CODE=0
    else
        FINAL_STATUS="FAIL"
        EXIT_CODE=1
    fi
fi

echo ""
echo "=================================================="
echo "FINAL_STATUS = $FINAL_STATUS"
echo "=================================================="
exit $EXIT_CODE
