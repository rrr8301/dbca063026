FROM gcc:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    cmake \
    ninja-build \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /usr/src/app

# Copy the repository into the container
COPY . .

# Copy the run.sh script and make it executable
COPY run.sh /usr/src/app/run.sh
RUN chmod +x /usr/src/app/run.sh

# Set the entrypoint to run.sh
ENTRYPOINT ["/usr/src/app/run.sh"]