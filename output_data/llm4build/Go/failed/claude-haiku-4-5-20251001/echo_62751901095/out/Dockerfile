FROM golang:1.25-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
ENV CGO_ENABLED=1

# Install required packages including build essentials for cgo
RUN apk add --no-cache \
    git \
    ca-certificates \
    tzdata \
    gcc \
    musl-dev

# Create work directory
WORKDIR /workspace

# Copy repository (will be mounted or copied by docker build context)
COPY . .

# Copy and set run.sh as entrypoint
# Use dos2unix to convert CRLF to LF, or use sed as fallback
COPY run.sh /run.sh
RUN sed -i 's/\r$//' /run.sh && chmod +x /run.sh

ENTRYPOINT ["/bin/sh", "/run.sh"]