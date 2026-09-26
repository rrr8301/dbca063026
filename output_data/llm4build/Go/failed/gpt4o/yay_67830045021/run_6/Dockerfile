FROM ghcr.io/jguer/yay-builder:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessary packages using pacman
RUN pacman -Syu --noconfirm \
    git \
    make \
    go \
    && yes | pacman -Scc --noconfirm || true

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . /app

# Ensure run.sh is executable
RUN if [ -f /app/run.sh ]; then chmod +x /app/run.sh; else echo "run.sh not found, skipping chmod."; fi

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]