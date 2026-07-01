FROM node:24-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    echo "America/Los_Angeles" > /etc/timezone

# Install required OS-level packages
RUN apk add --no-cache \
    git \
    curl \
    bash \
    build-base \
    python3

# Set working directory
WORKDIR /workspace

# Copy repository (assumes repo is mounted or copied)
COPY . .

# Install pnpm globally
RUN npm install -g pnpm

# Install @antfu/ni globally
RUN npm install -g @antfu/ni

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]