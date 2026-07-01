FROM golang:1.26-alpine

# Install system dependencies
RUN apk add --no-cache \
    git \
    build-base \
    redis \
    bash \
    ca-certificates

WORKDIR /app

# Copy the repository (from the repo subdirectory)
COPY repo/ /app/

# Copy the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
