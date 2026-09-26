FROM node:20-alpine

# Install pnpm
RUN npm install -g pnpm

# Set working directory
WORKDIR /workspace

# Copy project files
COPY . .

# Create and set permissions for run.sh
RUN chmod +x /workspace/run.sh

# Run the test script
ENTRYPOINT ["/workspace/run.sh"]