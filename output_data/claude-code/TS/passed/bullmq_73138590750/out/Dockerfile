FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_ENV=test

# Install system dependencies
RUN apt-get update && apt-get install -y \
  curl \
  wget \
  git \
  build-essential \
  python3 \
  && rm -rf /var/lib/apt/lists/*

# Install Node.js LTS
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
  apt-get install -y nodejs && \
  rm -rf /var/lib/apt/lists/*

# Install Redis
RUN apt-get update && apt-get install -y redis-server && \
  rm -rf /var/lib/apt/lists/*

# Install yarn
RUN npm install -g yarn@1.22.22

# Set working directory
WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Install project dependencies
RUN yarn install --ignore-engines --frozen-lockfile --non-interactive

# Copy the test runner script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
