FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    make \
    gcc \
    g++ \
    libossp-uuid-dev \
    postgresql \
    sudo \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Install MySQL from the official repository to avoid conflicts
RUN wget https://dev.mysql.com/get/mysql-apt-config_0.8.22-1_all.deb && \
    dpkg -i mysql-apt-config_0.8.22-1_all.deb && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server && \
    rm mysql-apt-config_0.8.22-1_all.deb && \
    rm -rf /var/lib/apt/lists/*

# Install Go
RUN wget https://golang.org/dl/go1.26.2.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.26.2.linux-amd64.tar.gz && \
    rm go1.26.2.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Install Go packages
RUN go install gotest.tools/gotestsum@latest && \
    go install github.com/sqlc-dev/sqlc-gen-test@v0.1.0 && \
    go install ./scripts/test-json-process-plugin/ && \
    CGO_ENABLED=0 go install ./...

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]