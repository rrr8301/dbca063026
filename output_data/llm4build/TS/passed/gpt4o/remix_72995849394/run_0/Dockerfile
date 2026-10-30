FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN curl -f https://get.pnpm.io/v6.16.js | node - add --global pnpm

# Create work directory
WORKDIR /app

# Copy repository files
COPY . .

# Install Node.js version specified in package.json
RUN pnpm env use --global $(node -p "require('./package.json').engines.node")

# Install project dependencies
RUN pnpm install --frozen-lockfile

# Install Playwright browsers
RUN pnpm --filter @remix-run/component exec playwright install --with-deps

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]