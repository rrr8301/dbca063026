FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    make \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install CMake 3.16.0
RUN curl -sL https://github.com/Kitware/CMake/releases/download/v3.16.0/cmake-3.16.0-Linux-x86_64.sh -o cmakeinstall.sh && \
    chmod +x cmakeinstall.sh && \
    ./cmakeinstall.sh --prefix=/usr/local --exclude-subdir && \
    rm cmakeinstall.sh

# Create work directory
WORKDIR /workspace

# Copy repository contents
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]