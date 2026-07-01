FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    make \
    gcc \
    g++ \
    cmake \
    ninja-build \
    gnupg \
    ca-certificates \
    xz-utils && \
    rm -rf /var/lib/apt/lists/*  # Corrected by adding RUN

# Install Go
RUN wget https://golang.org/dl/go1.17.6.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.17.6.linux-amd64.tar.gz && \
    rm go1.17.6.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Install Node.js using the official binary
RUN wget https://nodejs.org/dist/v14.21.3/node-v14.21.3-linux-x64.tar.xz && \
    tar -C /usr/local --strip-components=1 -xf node-v14.21.3-linux-x64.tar.xz && \
    rm node-v14.21.3-linux-x64.tar.xz

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Install Node.js dependencies
RUN npm install

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]