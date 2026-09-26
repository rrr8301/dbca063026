FROM node:24.14.1-alpine

# Install pnpm
RUN npm install -g pnpm

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Create scripts directory and copy entrypoint script
RUN mkdir -p /scripts
COPY run.sh /scripts/run.sh
RUN chmod +x /scripts/run.sh

# Set entrypoint
ENTRYPOINT ["/scripts/run.sh"]