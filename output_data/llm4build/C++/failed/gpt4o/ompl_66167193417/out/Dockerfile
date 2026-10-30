FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    libboost-program-options-dev \
    libboost-serialization-dev \
    libboost-test-dev \
    libeigen3-dev \
    libflann-dev \
    libtriangle-dev \
    libyaml-cpp-dev \
    git \
    cmake \
    make \
    g++ \
    python3.10 \
    python3-pip \
    ninja-build  # Add ninja-build to the list of installed packages

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Install Python dependencies for nanobinds
RUN cd nanobinds && pip install .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]