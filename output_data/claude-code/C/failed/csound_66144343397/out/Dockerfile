FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
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
    build-essential \
    git

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
