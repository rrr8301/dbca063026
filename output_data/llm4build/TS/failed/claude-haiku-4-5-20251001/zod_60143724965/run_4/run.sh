#!/bin/bash

set -e

# Print Node and pnpm versions for debugging
echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"
echo "pnpm version: $(pnpm --version)"

# Install project dependencies
echo "Installing dependencies with pnpm..."
pnpm install

# Add TypeScript latest
echo "Adding TypeScript latest..."
pnpm add typescript@latest -w

# Fix TypeScript 6.0 deprecation warnings in tsconfig files
echo "Updating tsconfig files to handle TypeScript 6.0 deprecations..."

update_tsconfig() {
    local file=$1
    if [ -f "$file" ]; then
        echo "Processing $file..."
        
        # Use a Python script to safely parse and modify JSON5-compatible files
        python3 << 'PYTHON_EOF'
import json
import sys
import re

file_path = sys.argv[1]

try:
    # Read the file
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Remove comments and trailing commas for parsing
    # Remove single-line comments
    content_clean = re.sub(r'//.*?$', '', content, flags=re.MULTILINE)
    # Remove multi-line comments
    content_clean = re.sub(r'/\*.*?\*/', '', content_clean, flags=re.DOTALL)
    # Remove trailing commas before closing braces/brackets
    content_clean = re.sub(r',(\s*[}\]])', r'\1', content_clean)
    
    # Parse JSON
    data = json.loads(content_clean)
    
    # Ensure compilerOptions exists
    if 'compilerOptions' not in data:
        data['compilerOptions'] = {}
    
    # Add ignoreDeprecations if it doesn't exist
    if 'ignoreDeprecations' not in data['compilerOptions']:
        data['compilerOptions']['ignoreDeprecations'] = '6.0'
        
        # Write back with proper formatting
        with open(file_path, 'w') as f:
            json.dump(data, f, indent=2)
        print(f"Successfully updated {file_path}")
    else:
        print(f"ignoreDeprecations already exists in {file_path}")
        
except Exception as e:
    print(f"Error processing {file_path}: {e}")
    sys.exit(1)
PYTHON_EOF
        python3 -c "
import json
import sys
import re

file_path = '$file'

try:
    with open(file_path, 'r') as f:
        content = f.read()
    
    content_clean = re.sub(r'//.*?\$', '', content, flags=re.MULTILINE)
    content_clean = re.sub(r'/\*.*?\*/', '', content_clean, flags=re.DOTALL)
    content_clean = re.sub(r',(\s*[}\]])', r'\1', content_clean)
    
    data = json.loads(content_clean)
    
    if 'compilerOptions' not in data:
        data['compilerOptions'] = {}
    
    if 'ignoreDeprecations' not in data['compilerOptions']:
        data['compilerOptions']['ignoreDeprecations'] = '6.0'
        
        with open(file_path, 'w') as f:
            json.dump(data, f, indent=2)
        print(f'Successfully updated {file_path}')
    else:
        print(f'ignoreDeprecations already exists in {file_path}')
        
except Exception as e:
    print(f'Error processing {file_path}: {e}')
    sys.exit(1)
"
    fi
}

update_tsconfig "/workspace/packages/zod/tsconfig.build.json"
update_tsconfig "/workspace/tsconfig.json"

# Build the project
echo "Building project..."
pnpm build

# Run main tests
echo "Running main tests..."
pnpm test || TEST_FAILED=1

# Run resolution tests
echo "Running resolution tests..."
pnpm run --filter @zod/resolution test:all || TEST_FAILED=1

# Run integration tests
echo "Running integration tests..."
pnpm run --filter @zod/integration test:all || TEST_FAILED=1

# Exit with failure if any test failed
if [ "$TEST_FAILED" = "1" ]; then
    echo "Some tests failed!"
    exit 1
fi

echo "All tests passed!"
exit 0