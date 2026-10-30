FROM debian:trixie

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    meson ninja-build qemu-user \
    python3-setuptools python3-jsonschema \
    python3-pexpect python3-pip netbase clang lld \
    git rsync wget patchelf libc6-dev-i386-cross \
    gcc-i686-linux-gnu g++-i686-linux-gnu \
    libstdc++-i686-dev

# Install Python packages
RUN pip install --break-system-packages -U xbstrap pyexpect

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]