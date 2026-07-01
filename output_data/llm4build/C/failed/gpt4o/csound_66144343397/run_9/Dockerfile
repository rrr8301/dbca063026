# Use an official Ubuntu as a parent image
FROM ubuntu:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
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
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Make the run.sh script executable
RUN chmod +x /app/run.sh

# Run the build script
CMD ["/app/run.sh"]