FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    tar \
    libatomic1 \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js using NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs

# Install pnpm using standalone script
RUN curl -fsSL https://get.pnpm.io/install.sh | bash -

# Add pnpm to PATH
ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

# Ensure pnpm is available
RUN /root/.local/share/pnpm/pnpm --version

# Use pnpm to manage Node.js version
RUN /root/.local/share/pnpm/pnpm env use --global 22.13.0

# Create work directory
WORKDIR /app

# Copy repository files
COPY . .

# Ensure pnpm installs dependencies
RUN /root/.local/share/pnpm/pnpm install

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]