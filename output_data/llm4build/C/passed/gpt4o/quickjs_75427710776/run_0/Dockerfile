FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    python3-pip \
    pipx \
    ninja-build \
    && apt-get clean

# Ensure pipx uses the correct Python version
ENV PIPX_DEFAULT_PYTHON=python3

# Create work directory
WORKDIR /app

# Copy the repository
COPY . .

# Install meson and ninja
RUN pipx install meson ninja

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]