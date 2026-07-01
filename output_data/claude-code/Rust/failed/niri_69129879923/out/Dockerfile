FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y \
    curl gcc clang libudev-dev libgbm-dev libxkbcommon-dev \
    libegl1-mesa-dev libwayland-dev libinput-dev libdbus-1-dev \
    libsystemd-dev libseat-dev libpipewire-0.3-dev libpango1.0-dev \
    libdisplay-info-dev ca-certificates

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

ENV PATH="/root/.cargo/bin:$PATH"

WORKDIR /app

COPY repo/ /app/

RUN cargo build --release --no-default-features 2>&1 | head -20 || true

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
