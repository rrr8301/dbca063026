FROM ubuntu:latest

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
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
    bison \
    flex \
    gettext \
    libsamplerate0-dev \
    libpipewire-0.3-dev \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and set entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]