FROM golang:1.25

ENV DEBIAN_FRONTEND=noninteractive

# Install additional system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy repository
COPY repo/ /app/

# Start redis in the background
RUN echo '#!/bin/bash\nredis-server --daemonize yes\nredis-cli ping\nexec /run.sh' > /entrypoint.sh && chmod +x /entrypoint.sh

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/entrypoint.sh"]
