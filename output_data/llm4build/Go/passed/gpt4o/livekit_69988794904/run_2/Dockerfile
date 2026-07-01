FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

# Install Go (updated to 1.25.0)
RUN wget https://go.dev/dl/go1.25.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.25.0.linux-amd64.tar.gz && \
    rm go1.25.0.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"

# Install Mage
RUN go install github.com/magefile/mage@latest

# Install Go packages
RUN go install github.com/gotesttools/gotestfmt/v2/cmd/gotestfmt@v2.4.1
RUN go install golang.org/x/tools/cmd/goimports@latest

# Ensure Go binaries are in PATH
ENV PATH="/root/go/bin:${PATH}"

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]