FROM gcc:15

ENV DEBIAN_FRONTEND=noninteractive
ENV CC=gcc
ENV CXX=g++

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      cmake \
      git \
      libssl-dev \
      python3 && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
