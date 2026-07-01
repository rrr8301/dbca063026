FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    gnupg \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install Zulu JDK 21
RUN wget -qO - https://repos.azul.com/azul-repo.key | gpg --dearmor -o /usr/share/keyrings/azul-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/azul-archive-keyring.gpg] https://repos.azul.com/zulu/deb stable main" | tee /etc/apt/sources.list.d/zulu.list && \
    apt-get update && apt-get install -y zulu21-jdk

# Install Node.js (required for Bazel build)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs

# Install Bazelisk
RUN curl -L https://github.com/bazelbuild/bazelisk/releases/download/v1.10.1/bazelisk-linux-amd64 -o /usr/local/bin/bazelisk && \
    chmod +x /usr/local/bin/bazelisk

# Install Bazel rules for shell tests
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Bazel rules for shell tests
RUN mkdir -p /app && cd /app && \
    echo 'load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")' > WORKSPACE && \
    echo 'http_archive(' >> WORKSPACE && \
    echo '    name = "bazel_skylib",' >> WORKSPACE && \
    echo '    urls = ["https://github.com/bazelbuild/bazel-skylib/releases/download/1.0.3/bazel-skylib-1.0.3.tar.gz"],' >> WORKSPACE && \
    echo '    strip_prefix = "bazel-skylib-1.0.3",' >> WORKSPACE && \
    echo ')' >> WORKSPACE

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]