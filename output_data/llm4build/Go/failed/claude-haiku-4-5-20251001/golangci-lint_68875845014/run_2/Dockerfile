FROM golang:1.26-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apk add --no-cache \
    git \
    curl \
    wget \
    build-base \
    ca-certificates

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set run.sh as entrypoint, converting line endings to LF
COPY run.sh /run.sh
RUN dos2unix /run.sh || sed -i 's/\r$//' /run.sh && chmod +x /run.sh

ENTRYPOINT ["/run.sh"]