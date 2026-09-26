FROM node:24.14.1-alpine

WORKDIR /workspace

# Install pnpm
RUN npm install -g pnpm

# Copy project files
COPY . .

# Copy run.sh script
COPY run.sh /workspace/run.sh

# Make script executable
RUN chmod +x /workspace/run.sh

# Set environment variable for Node.js memory
ENV NODE_OPTIONS="--max-old-space-size=7168"

# Run the test script
ENTRYPOINT ["/workspace/run.sh"]