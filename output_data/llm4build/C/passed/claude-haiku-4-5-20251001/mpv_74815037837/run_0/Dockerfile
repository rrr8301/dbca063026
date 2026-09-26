FROM registry.opensuse.org/home/mia/images/images/mpv-ci:stable-deps

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Set environment variables for build
ENV CC=gcc
ENV CXX=g++

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]