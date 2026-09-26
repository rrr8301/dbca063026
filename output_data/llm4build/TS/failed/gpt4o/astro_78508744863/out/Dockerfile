FROM ubuntu:22.04

# Set environment variables
ENV TZ=UTC
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV NODE_OPTIONS=--max-old-space-size=6144
ENV FORCE_COLOR=true
ENV ASTRO_TELEMETRY_DISABLED=true

# Set locale to UTF-8
RUN apt-get update && \
    apt-get install -y locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Install required packages
RUN apt-get install -y git curl wget

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs

# Install PNPM
RUN npm install -g pnpm

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

# Install dependencies
RUN pnpm install

# Build packages
RUN pnpm run build

# Entry point
CMD ["bash", "/workspace/run.sh"]