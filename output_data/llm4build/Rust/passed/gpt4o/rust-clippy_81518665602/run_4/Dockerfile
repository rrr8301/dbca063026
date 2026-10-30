FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
RUN echo "UTC" > /etc/timezone && ln -sf /usr/share/zoneinfo/UTC /etc/localtime && apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    tzdata \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install Rust as the testuser
RUN useradd -m testuser
WORKDIR /home/testuser
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | su testuser -c "sh -s -- -y"
ENV PATH="/home/testuser/.cargo/bin:${PATH}"

WORKDIR /workspace
COPY . /workspace
RUN git config --global --add safe.directory '*'

COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

USER testuser
ENTRYPOINT ["/workspace/run.sh"]