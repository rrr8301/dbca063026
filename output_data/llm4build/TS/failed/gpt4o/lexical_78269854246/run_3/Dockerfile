FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and pnpm
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g pnpm

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Create non-root user and switch to it
RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

# Ensure pnpm is in the PATH for the user
ENV PATH="/home/testuser/.local/bin:${PATH}"

# Make run.sh executable
RUN chmod +x ./run.sh

# Install project dependencies
RUN pnpm install --frozen-lockfile

# Set the entrypoint to run.sh
ENTRYPOINT ["./run.sh"]