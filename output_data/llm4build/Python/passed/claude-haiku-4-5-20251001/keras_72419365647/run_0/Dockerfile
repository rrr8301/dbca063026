FROM python:3.11-slim

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set GitHub Actions environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install binary dependencies
RUN apt-get update && apt-get -y install \
    build-essential \
    curl \
    git \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Set KERAS_HOME
ENV KERAS_HOME=/workspace/.github/workflows/config/tensorflow

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]