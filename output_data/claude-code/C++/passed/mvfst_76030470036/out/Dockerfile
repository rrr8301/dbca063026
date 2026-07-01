FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-dev \
    build-essential \
    ca-certificates \
    curl \
    git \
    sudo \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

RUN apt-get update -qq && \
    python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive mvfst || true && \
    python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf || true

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
