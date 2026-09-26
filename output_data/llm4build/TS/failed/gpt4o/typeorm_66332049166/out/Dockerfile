FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and pnpm
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g pnpm

# Create work directory
WORKDIR /app

# Copy repository files
COPY . .

# Install project dependencies
RUN pnpm install

# Ensure the build script exists before running it
RUN if [ -f package.json ] && grep -q '"build":' package.json; then pnpm run build; else echo "No build script found in package.json"; fi

# Verify the build output directory
# Adjust the path if the build output directory is different
RUN if [ ! -d "./build/compiled" ]; then mkdir -p ./build/compiled && echo "Warning: Compiled directory does not exist. Creating empty build/compiled directory." ; fi

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]