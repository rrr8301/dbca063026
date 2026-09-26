FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    git \
    clang \
    libomp-dev \
    cmake \
    ninja-build \
    make \
    python3.10 \
    python3-pip \
    && apt-get clean

# Set up Python environment
RUN python3.10 -m pip install --upgrade pip

# Install Python dependencies
RUN python3.10 -m pip install \
    pybind11==3.0 \
    cmake==3.30.0 \
    ninja==1.11.1 \
    pytest \
    scikit-build-core \
    setuptools_scm

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]