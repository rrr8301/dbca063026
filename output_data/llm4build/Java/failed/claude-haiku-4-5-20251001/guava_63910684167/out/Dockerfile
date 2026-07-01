FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=America/Los_Angeles \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    CI=true \
    GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    build-essential \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Install Temurin JDK 11 and 25
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install JDK 25 from Temurin (not in standard Ubuntu repos)
RUN mkdir -p /opt/java && \
    curl -fsSL https://api.adoptium.net/v3/binary/latest/25/ga/linux/x64/jdk/hotspot/normal/eclipse \
    -o /tmp/jdk25.tar.gz && \
    tar -xzf /tmp/jdk25.tar.gz -C /opt/java && \
    rm /tmp/jdk25.tar.gz && \
    ln -s /opt/java/jdk-25* /opt/java/jdk25

# Set JAVA_HOME to JDK 11 (default for Maven)
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 \
    PATH=/usr/lib/jvm/java-11-openjdk-amd64/bin:$PATH

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git to trust the workspace directory
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Create Maven toolchains configuration for JDK 11 and 25
RUN mkdir -p /home/testuser/.m2 && \
    printf '%s\n' \
    '<?xml version="1.0" encoding="UTF-8"?>' \
    '<toolchains>' \
    '  <toolchain>' \
    '    <type>jdk</type>' \
    '    <provides>' \
    '      <version>11</version>' \
    '    </provides>' \
    '    <configuration>' \
    '      <jdkHome>/usr/lib/jvm/java-11-openjdk-amd64</jdkHome>' \
    '    </configuration>' \
    '  </toolchain>' \
    '  <toolchain>' \
    '    <type>jdk</type>' \
    '    <provides>' \
    '      <version>25</version>' \
    '    </provides>' \
    '    <configuration>' \
    '      <jdkHome>/opt/java/jdk25</jdkHome>' \
    '    </configuration>' \
    '  </toolchain>' \
    '</toolchains>' \
    > /home/testuser/.m2/toolchains.xml

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]