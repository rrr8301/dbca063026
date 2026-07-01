FROM registry.opensuse.org/home/mia/images/images/mpv-ci:stable-deps

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set compiler environment variables
ENV CC=gcc
ENV CXX=g++

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Make all shell scripts in ci directory executable
RUN chmod +x /workspace/ci/*.sh

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]