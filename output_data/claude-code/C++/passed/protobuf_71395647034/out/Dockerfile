FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    python3 \
    python3-pip \
    wget \
    default-jdk \
    libffi-dev \
    libssl-dev \
    pkg-config \
    unzip \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Install GCC 9
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc-9 \
    g++-9 \
    && rm -rf /var/lib/apt/lists/*

# Set GCC 9 as default
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 90 && \
    update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 90

# Install Bazel 8.0.1
RUN curl -fsSL https://github.com/bazelbuild/bazel/releases/download/8.0.1/bazel-8.0.1-linux-x86_64 \
    -o /usr/local/bin/bazel && \
    chmod +x /usr/local/bin/bazel

WORKDIR /app
COPY repo /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
