FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  cmake \
  ninja-build \
  g++-12 \
  gcc-12 \
  git \
  build-essential \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
