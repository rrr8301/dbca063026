FROM node:24.14.1-alpine

# Install pnpm
RUN npm install -g pnpm

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Copy and set up entrypoint script
COPY run.sh /scripts/run.sh
RUN chmod +x /scripts/run.sh

# Set entrypoint
ENTRYPOINT ["/scripts/run.sh"]