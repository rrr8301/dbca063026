FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    software-properties-common

# Install Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Add deadsnakes PPA for Python 3.12
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.12 python3.12-venv python3.12-dev

# Upgrade pip and install Python packages
RUN python3.12 -m ensurepip && \
    python3.12 -m pip install --upgrade pip wheel "setuptools<80.0.0"

# Install additional Python packages with --ignore-installed
RUN python3.12 -m pip install --ignore-installed pytest pydantic dash

# Install Dash development tools
RUN npm install -g dash-generate-components

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Install Node.js dependencies
RUN npm ci

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]