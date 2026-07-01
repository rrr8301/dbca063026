FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=UTC
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    tzdata \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Zulu JDK 25
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    && add-apt-repository -y ppa:zulu/ubuntu \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    zulu-25-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/zulu-25-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser
RUN chown -R testuser /workspace

# Switch to non-root user
USER testuser

# Copy and make run.sh executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]