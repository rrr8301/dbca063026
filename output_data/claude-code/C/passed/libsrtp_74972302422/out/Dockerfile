FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    cmake \
    make \
    gcc \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

RUN mkdir -p /app/build

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENV CTEST_OUTPUT_ON_FAILURE=1

ENTRYPOINT ["/run.sh"]
