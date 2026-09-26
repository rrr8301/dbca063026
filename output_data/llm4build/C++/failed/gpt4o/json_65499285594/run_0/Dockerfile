FROM gcc:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    cmake \
    ninja-build \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /usr/src/app

# Copy the repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/src/app/run.sh
RUN chmod +x /usr/src/app/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/src/app/run.sh"]