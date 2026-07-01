FROM node:22-slim

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create and set working directory
WORKDIR /repo

# Copy repository
COPY . .

# Install npm dependencies
RUN npm ci

# Copy and set run script as entrypoint
COPY run.sh /repo/run.sh
RUN chmod +x /repo/run.sh

ENTRYPOINT ["/repo/run.sh"]