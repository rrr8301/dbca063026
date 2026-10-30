FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
RUN echo "UTC" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -y tzdata

ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN apt-get update && \
    apt-get install -y curl gcc clang libudev-dev libgbm-dev libxkbcommon-dev libegl1-mesa-dev libwayland-dev libinput-dev libdbus-1-dev libsystemd-dev libseat-dev libpipewire-0.3-dev libpango1.0-dev git

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Ensure the Rust environment is available for the root user
RUN /root/.cargo/bin/rustup toolchain install stable --profile minimal --component clippy
RUN /root/.cargo/bin/rustup default stable

WORKDIR /workspace
COPY . /workspace
RUN git config --global --add safe.directory '*'

COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

RUN useradd -m testuser && chown -R testuser /workspace

# Switch to testuser
USER testuser

# Initialize Rust environment for testuser
RUN /root/.cargo/bin/rustup target add x86_64-unknown-linux-gnu --toolchain stable
RUN /root/.cargo/bin/rustup component add clippy --toolchain stable

# Copy Rust environment to testuser
RUN echo 'source $HOME/.cargo/env' >> /home/testuser/.bashrc

# Set the entrypoint to run.sh
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]