FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    zstd \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Java - using openjdk from Ubuntu repos
RUN apt-get update && \
    apt-get install -y openjdk-21-jdk && \
    rm -rf /var/lib/apt/lists/*

# Install Maven
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

# Install Node.js and pnpm (needed for UI builds)
RUN apt-get update && apt-get install -y nodejs npm && \
    npm install -g pnpm && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

# Set environment variables
ENV MAVEN_ARGS="-B -nsu -Daether.connector.http.connectionMaxTtl=25"
ENV SUREFIRE_RERUN_FAILING_COUNT=2
ENV SUREFIRE_RETRY="-Dsurefire.rerunFailingTestsCount=2"
ENV KC_TEST_GITHUB_SLOW_METHOD="10"
ENV KC_TEST_GITHUB_SLOW_CLASS="60"

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
