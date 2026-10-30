FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
RUN echo "UTC" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    cmake \
    make \
    ccache \
    python3.12 \
    python3.12-venv \
    python3.12-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

WORKDIR /workspace

COPY . /workspace
RUN git config --global --add safe.directory '*'

COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

ENTRYPOINT ["/workspace/run.sh"]