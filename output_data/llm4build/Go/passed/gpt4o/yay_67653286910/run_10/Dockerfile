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
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]