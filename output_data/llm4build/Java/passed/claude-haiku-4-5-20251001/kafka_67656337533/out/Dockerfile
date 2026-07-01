FROM ubuntu:24.04

# Set timezone to Pacific Time non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    build-essential \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.12
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.12 \
    python3.12-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.12 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1

# Install Java 25 (Temurin)
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-25-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-25-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Set default timeout (can be overridden at runtime)
ENV TIMEOUT_MINUTES=180

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Install Python dependencies from requirements.txt
# Using --break-system-packages to work around PEP 668 in Ubuntu 24.04
RUN pip install --no-cache-dir --break-system-packages -r .github/scripts/requirements.txt

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
# Convert line endings to Unix format and set executable permissions
RUN dos2unix /workspace/run.sh && chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]