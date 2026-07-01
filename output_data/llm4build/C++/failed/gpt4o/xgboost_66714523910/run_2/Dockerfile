# Use build arguments for Docker registry and image tag
ARG DOCKER_REGISTRY
ARG IMAGE_TAG

# Provide default values for the build arguments to avoid errors if not passed
FROM ${DOCKER_REGISTRY:-default_registry}/xgb-ci.cpu:${IMAGE_TAG:-latest}

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessary packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]