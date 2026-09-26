FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessary packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and pnpm
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g pnpm

# Create work directory
WORKDIR /app

# Copy repository files
COPY . .

# Ensure run.sh is present in the build context
# Make sure run.sh is in the same directory as the Dockerfile or adjust the path accordingly
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Install project dependencies
RUN pnpm install --frozen-lockfile

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]