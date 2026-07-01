FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    cmake \
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
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /csound

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]