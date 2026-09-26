FROM golang:1.25-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles

# Install required packages
RUN apk add --no-cache \
    git \
    ca-certificates \
    tzdata

# Create work directory
WORKDIR /workspace

# Copy repository (will be mounted or copied by docker build context)
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]