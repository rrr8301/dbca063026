FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/usr/local/bin:$PATH

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    openjdk-17-jdk \
    unzip \
    ca-certificates \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @bazel/bazelisk

WORKDIR /app

COPY repo/ /app/

RUN git config --global --add safe.directory /app

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
