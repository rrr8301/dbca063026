FROM ubuntu:rolling

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set environment variables
ENV DEVELOPER=1
ENV CC=gcc
ENV CUSTOM_PATH=/custom
ENV DEBIAN_FRONTEND=noninteractive
ENV GITHUB_ACTIONS=true
ENV CI=true

# Install dependencies
RUN apt-get -q update && apt-get -q -y install \
    git \
    gcc \
    g++ \
    make \
    cmake \
    ninja-build \
    meson \
    pkg-config \
    curl \
    wget \
    sudo \
    gettext \
    openssl \
    libssl-dev \
    libcurl4-openssl-dev \
    zlib1g-dev \
    perl \
    asciidoc \
    cargo \
    rustc \
    libexpat1-dev \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /repo

# Copy repository
COPY . .

# Fix permissions for all shell scripts and executable files
RUN find . -type f -name "*.sh" -exec chmod +x {} \; && \
    find . -type f -name "generate-*" -exec chmod +x {} \; && \
    find ci -type f -exec chmod +x {} \;

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Set entrypoint
ENTRYPOINT ["/run.sh"]