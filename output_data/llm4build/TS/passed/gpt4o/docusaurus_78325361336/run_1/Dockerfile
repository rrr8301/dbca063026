FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=UTC
RUN apt-get update && apt-get install -y tzdata && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && dpkg-reconfigure --frontend noninteractive tzdata
ENV LANG=C.UTF-8

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    libatomic1 \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and Yarn
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash \
    && export NVM_DIR="$HOME/.nvm" \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && nvm install 26 \
    && nvm use 26 \
    && npm install -g yarn

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

# Install project dependencies
RUN yarn install --frozen-lockfile || yarn install --frozen-lockfile || yarn install --frozen-lockfile