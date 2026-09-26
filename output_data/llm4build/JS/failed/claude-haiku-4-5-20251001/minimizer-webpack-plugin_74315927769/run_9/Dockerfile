FROM node:14

WORKDIR /workspace

RUN bash -c 'cat > /workspace/run.sh << '"'"'EOF'"'"'
#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Install dependencies with TypeScript 4 (force to allow peer dependency conflicts)
npm install -D typescript@4 --force
npm install --ignore-scripts

# Install older cssnano for Node 14/16 compatibility
npm install -D --no-save cssnano@^6 --force

# Run tests with coverage and CI flag
npm run test:coverage -- --ci

echo "All tests completed successfully!"
EOF
'

RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]