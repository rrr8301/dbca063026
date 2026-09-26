FROM alpine:3.23

# Set timezone to Pacific Time and environment variables
ENV TZ=America/Los_Angeles \
    CI=true \
    GITHUB_ACTIONS=true

# Install dependencies
RUN apk add --no-cache \
    build-base \
    cmake \
    linux-headers \
    git \
    tzdata

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git safe directory to avoid ownership errors
RUN git config --global --add safe.directory '*'

# Copy and set run.sh as entrypoint
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]