FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install OS-level dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    curl \
    wget \
    make \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24.x from official binary
RUN curl -fsSL https://nodejs.org/dist/v24.0.0/node-v24.0.0-linux-x64.tar.xz | tar -xJ -C /usr/local --strip-components=1

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Enable corepack and install pnpm
RUN npm i -g corepack@latest && corepack enable

# Install project dependencies
RUN make install

# Install Cypress binary
RUN cd packages/volto && make cypress-install

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]