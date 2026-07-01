FROM rust:1.92.0

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    libclang-dev \
    libgtk-3-dev \
    libxcb-render0-dev \
    libxcb-shape0-dev \
    libxcb-xfixes0-dev \
    libxkbcommon-dev \
    libssl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create work directory
WORKDIR /app

# Copy the run.sh script and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set the entrypoint to run.sh
ENTRYPOINT ["/usr/local/bin/run.sh"]