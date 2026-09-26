FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install locales and set UTF-8
RUN apt-get update && apt-get install -y locales && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install build dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    cmake \
    autoconf \
    automake \
    libtool \
    pkg-config \
    libcppunit-dev \
    libsasl2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install JDK 11 (Temurin)
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Install Maven (official binary to avoid distro version issues)
RUN mkdir -p /opt/maven && \
    curl -fsSL https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz | \
    tar -xz -C /opt/maven --strip-components=1 && \
    ln -s /opt/maven/bin/mvn /usr/local/bin/mvn

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git to allow ownership mismatch (MUST be done as root before switching users)
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser

# Change ownership of workspace to testuser
RUN chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]