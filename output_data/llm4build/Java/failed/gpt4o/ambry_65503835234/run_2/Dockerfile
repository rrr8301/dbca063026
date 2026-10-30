FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=UTC
RUN apt-get update && apt-get install -y tzdata && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && dpkg-reconfigure --frontend noninteractive tzdata
ENV LANG=C.UTF-8

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    openjdk-11-jdk \
    mysql-server \
    curl \
    wget

# Install Node.js (LTS version) and npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Create a non-root user
RUN useradd -m testuser
WORKDIR /workspace
RUN chown -R testuser /workspace
USER testuser

# Copy the repository
COPY . /workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Install Azurite
USER root
RUN npm install -g azurite

# Ensure gradlew is executable
RUN chmod +x /workspace/gradlew

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]