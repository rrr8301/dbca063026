FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    make \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Go (assuming version 1.20.9 as a plausible version)
RUN wget https://golang.org/dl/go1.20.9.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.20.9.linux-amd64.tar.gz && \
    rm go1.20.9.linux-amd64.tar.gz

# Set Go environment variables
ENV PATH="/usr/local/go/bin:${PATH}"

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]