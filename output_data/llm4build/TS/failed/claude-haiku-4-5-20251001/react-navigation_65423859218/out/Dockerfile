FROM node:20-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install system dependencies
RUN apk add --no-cache \
    ca-certificates \
    git \
    curl \
    python3 \
    build-base

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Install dependencies
RUN yarn install --immutable

# Run tests directly without entrypoint script
CMD ["yarn", "test", "--maxWorkers=2", "--coverage"]