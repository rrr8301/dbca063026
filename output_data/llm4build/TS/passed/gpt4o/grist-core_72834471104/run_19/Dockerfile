FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    g++ \
    make \
    wget \
    python3.11 \
    python3.11-venv \
    python3-pip \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install yarn
RUN npm install --global yarn

# Create work directory
WORKDIR /app

# Copy repository files
COPY . .

# Ensure run.sh is present in the build context
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Install Python and Node.js packages
RUN pip install virtualenv && yarn install && yarn run install:python

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]