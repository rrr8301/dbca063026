FROM rust:1.89

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_TERM_COLOR=always

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo /app/

RUN rustc --version && cargo --version

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
