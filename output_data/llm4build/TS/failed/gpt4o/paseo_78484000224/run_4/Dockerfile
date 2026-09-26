FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (using Node.js 20 as Node.js 22 is not available)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Create a non-root user
RUN useradd -m testuser
WORKDIR /workspace

# Copy the repository
COPY . /workspace

# Change ownership of the workspace directory and its contents
RUN chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Configure git
RUN git config --global --add safe.directory '*'

# Install project dependencies
RUN npm ci

# Switch back to root user to install Playwright dependencies
USER root

# Install Playwright dependencies
RUN npx playwright install --with-deps chromium

# Switch back to non-root user
USER testuser