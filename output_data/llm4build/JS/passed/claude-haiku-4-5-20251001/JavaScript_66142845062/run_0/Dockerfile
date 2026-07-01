FROM node:22-slim

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install required system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create and set working directory
WORKDIR /repo

# Copy repository
COPY . .

# Install npm dependencies
RUN npm ci

# Copy and set run.sh as entrypoint
COPY run.sh /repo/run.sh
RUN chmod +x /repo/run.sh

ENTRYPOINT ["/repo/run.sh"]