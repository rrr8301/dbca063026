FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Set locale to UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    && locale-gen en_US.UTF-8 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    make \
    curl \
    wget \
    ca-certificates \
    maven \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Java 25 (build JDK) and Java 17 (test JDK)
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-25-jdk \
    openjdk-17-jdk \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME to Java 25 for build (will switch to 17 for tests in run.sh)
ENV JAVA_HOME=/usr/lib/jvm/java-25-openjdk-amd64

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git to allow ownership mismatch
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser
RUN chown -R testuser /workspace

# Switch to non-root user
USER testuser

# Set Maven arguments
ENV MAVEN_ARGS="-B -ff"

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]