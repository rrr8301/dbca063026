FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
      ccache \
      cmake \
      ninja-build \
      gcc \
      g++ \
      make \
      git

WORKDIR /app
COPY repo/ /app/

RUN mkdir -p ~/.ccache && \
    echo "max_size = 250M" > ~/.ccache/ccache.conf && \
    echo "compression = true" >> ~/.ccache/ccache.conf

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
