FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=UTC
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    locales \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV REACT=18
ENV SKIP_SEMANTIC=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    python3-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (LTS version compatible with ubuntu-24.04)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Verify Node.js and npm installation
RUN node --version && npm --version

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git for safe directory
RUN git config --global --add safe.directory '*'

# Install utoo globally (assuming it's available on npm)
RUN npm install -g utoo || echo "utoo not found on npm, will install from source if needed"

# Install project dependencies
RUN npm install

# Create non-root user
RUN useradd -m testuser
RUN chown -R testuser:testuser /workspace

# Copy run.sh and set permissions BEFORE switching to non-root user
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Switch to non-root user
USER testuser

ENTRYPOINT ["/workspace/run.sh"]