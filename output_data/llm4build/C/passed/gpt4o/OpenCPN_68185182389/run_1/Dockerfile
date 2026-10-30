FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    make \
    g++ \
    curl \
    wget \
    pkg-config \
    libgtk-3-dev \
    libgl1-mesa-dev \
    libwxgtk3.0-gtk3-dev

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Ensure pre-build script is executable
RUN chmod +x /app/ci/github-pre-build.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]