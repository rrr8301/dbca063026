FROM node:24-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    echo "America/Los_Angeles" > /etc/timezone

# Install required packages
RUN apk add --no-cache \
    git \
    bash \
    curl \
    build-base \
    python3

# Set npm configuration
ENV npm_config_audit=false \
    npm_config_fund=false \
    npm_config_save=false \
    npm_config_package_lock=false \
    FORCE_COLOR=3

# Create and set working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Install dependencies
RUN npm ci

# Copy and set run script as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]