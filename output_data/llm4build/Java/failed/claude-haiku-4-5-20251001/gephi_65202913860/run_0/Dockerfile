FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=UTC
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    locales \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    CI=true \
    GITHUB_ACTIONS=true

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install JDK 17 (Temurin) via SDKMAN
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -s "https://get.sdkman.io" | bash && \
    bash -c 'source /root/.sdkman/bin/sdkman-init.sh && \
    sdk install java 17.0.9-tem && \
    sdk default java 17.0.9-tem'

ENV PATH="/root/.sdkman/candidates/java/current/bin:${PATH}"

# Install Maven via official binary
RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz | \
    tar -xz -C /opt && \
    ln -s /opt/apache-maven-3.9.6 /opt/maven

ENV PATH="/opt/maven/bin:${PATH}" \
    MAVEN_HOME="/opt/maven"

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace

USER testuser

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]