FROM node:lts-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    echo "America/Los_Angeles" > /etc/timezone

# Install required packages
RUN apk add --no-cache \
    git \
    curl \
    ca-certificates \
    bash \
    python3 \
    make \
    g++

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Create jest cache directory
RUN mkdir -p .jest-cache

# Install yarn dependencies
RUN yarn install --frozen-lockfile

# Copy and set entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]