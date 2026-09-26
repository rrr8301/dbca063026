FROM alpine:3.23

# Set timezone to Pacific Time
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    echo "America/Los_Angeles" > /etc/timezone && \
    apk del tzdata

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install dependencies
RUN apk add --no-cache build-base cmake linux-headers git

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Ensure run.sh is copied correctly and has the right permissions
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]