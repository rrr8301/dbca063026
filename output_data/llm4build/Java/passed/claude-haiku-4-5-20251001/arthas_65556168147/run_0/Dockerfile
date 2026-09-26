FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=UTC
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Java 25 (Zulu distribution)
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-25-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install Maven (official binary, not distro version)
RUN mkdir -p /opt/maven && \
    curl -fsSL https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz | \
    tar -xz -C /opt/maven --strip-components=1 && \
    ln -s /opt/maven/bin/mvn /usr/local/bin/mvn

# Install Node.js and Yarn (for UI subproject)
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*
RUN npm install -g yarn

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace

# Configure git to trust the workspace directory
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser
RUN chown -R testuser:testuser /workspace
USER testuser

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]