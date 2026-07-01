FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=UTC
RUN apt-get update && apt-get install -y tzdata && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && dpkg-reconfigure --frontend noninteractive tzdata
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    make \
    g++ \
    python3 \
    python3-pip \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Check if the requirements file exists and install Python dependencies
RUN if [ -f "qpdf/manual/requirements.txt" ]; then pip3 install -r qpdf/manual/requirements.txt; fi

# Ensure build script is executable
RUN chmod +x build-scripts/build-linux

# Create a non-root user
RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

# Set the entrypoint to run.sh
ENTRYPOINT ["bash", "run.sh"]