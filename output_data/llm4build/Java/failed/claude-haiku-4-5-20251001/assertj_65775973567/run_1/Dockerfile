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
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Zulu JDK 25 using official Azul repository
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    && wget -qO - https://repos.azul.com/azul-repo.key | apt-key add - \
    && add-apt-repository "deb https://repos.azul.com/ubuntu stable main" \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    zulu-25-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/zulu-25-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Install Maven
RUN apt-get update && apt-get install -y --no-install-recommends \
    maven \
    && rm -rf /var/lib/apt/lists/*

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