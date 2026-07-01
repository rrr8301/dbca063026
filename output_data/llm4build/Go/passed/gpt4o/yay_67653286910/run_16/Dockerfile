FROM ghcr.io/jguer/yay-builder:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles

# Install necessary packages using pacman
RUN pacman -Syu --noconfirm \
    git \
    make

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . /app

# Ensure run.sh is in the correct location
RUN if [ -f /app/run.sh ]; then chmod +x /app/run.sh; else echo "run.sh not found"; exit 1; fi

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]