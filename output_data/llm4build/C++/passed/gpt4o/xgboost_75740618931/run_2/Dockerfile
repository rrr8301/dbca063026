FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    make \
    g++ \
    clang \
    curl \
    wget \
    python3-pip \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

# Install sccache
RUN curl -L https://github.com/mozilla/sccache/releases/download/v0.2.15/sccache-v0.2.15-x86_64-unknown-linux-musl.tar.gz | tar xz && \
    mv sccache-v0.2.15-x86_64-unknown-linux-musl/sccache /usr/local/bin/ && \
    rm -rf sccache-v0.2.15-x86_64-unknown-linux-musl

# Install Python testing packages
RUN pip3 install pytest

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]