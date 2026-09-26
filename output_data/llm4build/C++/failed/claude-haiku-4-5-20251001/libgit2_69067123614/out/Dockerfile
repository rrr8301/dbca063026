FROM ubuntu:noble

# Set timezone non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    cmake \
    ninja-build \
    clang \
    llvm \
    libclang-rt-18-dev \
    make \
    python3 \
    python3-pip \
    libssl-dev \
    libssh2-1-dev \
    libpcre3-dev \
    zlib1g-dev \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /home/libgit2

# Copy repository
COPY . /home/libgit2/source

# Copy run script
COPY run.sh /home/libgit2/run.sh
RUN chmod +x /home/libgit2/run.sh

# Set entrypoint
ENTRYPOINT ["/home/libgit2/run.sh"]