FROM ubuntu:rolling

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    gcc \
    meson \
    sudo \
    make \
    cmake \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy the repository into the container
COPY . .

# Ensure scripts have executable permissions
RUN chmod +x /workspace/ci/install-dependencies.sh /workspace/ci/run-build-and-tests.sh

# Copy and set permissions for run.sh
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]