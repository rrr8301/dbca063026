FROM docker:20.10-dind

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apk update && apk add --no-cache \
    ca-certificates \
    curl \
    git \
    bash \
    make

# Install Go 1.25.x
RUN curl -fsSL https://go.dev/dl/go1.25.0.linux-amd64.tar.gz | tar -C /usr/local -xz

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# Create app directory
WORKDIR /app

# Copy the entire repo
COPY repo/ /app/

# Set coverage directory
ENV COVERAGE_DIR=/tmp/coverage

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
