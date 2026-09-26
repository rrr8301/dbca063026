FROM ubuntu:24.04

# Set timezone to Pacific Time (non-interactive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install JDK 25 (Zulu)
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-25-jdk \
    && rm -rf /var/lib/apt/lists/*

# Verify Java installation
RUN java -version

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and make run.sh executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]