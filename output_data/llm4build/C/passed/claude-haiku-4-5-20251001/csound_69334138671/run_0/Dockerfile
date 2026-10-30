FROM ubuntu:22.04

# Set timezone to Pacific Time and disable interactive prompts
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    make \
    bison \
    flex \
    gettext \
    libgtest-dev \
    libsndfile1-dev \
    libasound2-dev \
    libjack-dev \
    portaudio19-dev \
    libportmidi-dev \
    libpulse-dev \
    swig \
    liblua5.1-0-dev \
    default-jdk \
    liblo-dev \
    ladspa-sdk \
    dssi-dev \
    libsamplerate0-dev \
    libpipewire-0.3-dev \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]