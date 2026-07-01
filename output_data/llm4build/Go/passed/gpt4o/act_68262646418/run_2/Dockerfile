FROM ubuntu:22.04

# Set timezone to avoid tzdata prompts
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    make

# Install Go (update to a compatible version)
RUN wget https://golang.org/dl/go1.20.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.20.0.linux-amd64.tar.gz && \
    rm go1.20.0.linux-amd64.tar.gz

# Set Go environment
ENV PATH="/usr/local/go/bin:${PATH}"

# Install Go test tool
RUN go install gotest.tools/gotestsum@latest

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Install Go dependencies
RUN go mod download

# Copy run.sh and set as entrypoint
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh
ENTRYPOINT ["/app/run.sh"]