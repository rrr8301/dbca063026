FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    BUILD_TYPE=Debug

RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    build-essential \
    git \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN cmake -B build -DQPP_ENABLE_TESTING=ON

RUN cmake --install build

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
