#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== TypeORM Test Suite ===${NC}"

# Ensure build directory exists
if [ ! -d "build" ]; then
    echo -e "${YELLOW}Build directory not found, compiling...${NC}"
    pnpm run compile
fi

# Install dependencies (in case they weren't installed in Dockerfile)
echo -e "${YELLOW}Installing dependencies...${NC}"
pnpm install

# Configure database for MySQL/MariaDB tests
echo -e "${YELLOW}Configuring database for MySQL/MariaDB...${NC}"
jq 'map(select(.type == "mysql" or .type == "mariadb"))' ormconfig.sample.json > ormconfig.json

# Display configuration
echo -e "${YELLOW}ORM Configuration:${NC}"
cat ormconfig.json

# Run tests with coverage
echo -e "${YELLOW}Running tests with coverage...${NC}"
TEST_FAILED=0
pnpm exec c8 pnpm run test:ci || TEST_FAILED=1

# Summary
echo ""
echo -e "${YELLOW}=== Test Execution Summary ===${NC}"
if [ $TEST_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. Check output above for details.${NC}"
    exit 1
fi